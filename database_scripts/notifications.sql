CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    habit_id UUID REFERENCES public.habits(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS unique_new_follower_notification
ON public.notifications (receiver_id, sender_id, type)
WHERE type = 'new_follower';

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuaris poden veure les seves notificacions" ON public.notifications;
CREATE POLICY "Usuaris poden veure les seves notificacions" ON public.notifications FOR SELECT USING (auth.uid() = receiver_id);

DROP POLICY IF EXISTS "Usuaris poden marcar com llegides les seves notificacions" ON public.notifications;
CREATE POLICY "Usuaris poden marcar com llegides les seves notificacions" ON public.notifications FOR UPDATE USING (auth.uid() = receiver_id);

DROP POLICY IF EXISTS "Usuaris poden esborrar les seves notificacions" ON public.notifications;
CREATE POLICY "Usuaris poden esborrar les seves notificacions" ON public.notifications FOR DELETE USING (auth.uid() = receiver_id);

CREATE OR REPLACE FUNCTION public.create_follow_notification()
RETURNS TRIGGER AS $$
DECLARE
    v_notif_id UUID;
BEGIN
    SELECT id INTO v_notif_id
    FROM public.notifications
    WHERE receiver_id = NEW.following_id
      AND sender_id = NEW.follower_id
      AND type = 'new_follower';

    IF v_notif_id IS NULL THEN
        INSERT INTO public.notifications (receiver_id, sender_id, type, is_read, created_at)
        VALUES (NEW.following_id, NEW.follower_id, 'new_follower', FALSE, NOW());
    ELSE
        UPDATE public.notifications
        SET is_read = FALSE, created_at = NOW()
        WHERE id = v_notif_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_follow_created ON public.follows;
CREATE TRIGGER on_follow_created
AFTER INSERT ON public.follows
FOR EACH ROW EXECUTE PROCEDURE public.create_follow_notification();

CREATE OR REPLACE FUNCTION public.notify_group_habit_completed()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.habits WHERE id = NEW.habit_id AND is_group = true) THEN
        INSERT INTO public.notifications (receiver_id, sender_id, type, habit_id, created_at)
        SELECT
            ph.user_id,
            NEW.user_id,
            'group_habit_completed',
            NEW.habit_id,
            NOW()
        FROM public.participacions_habits ph
        WHERE ph.habit_grupal_id = NEW.habit_id
        AND ph.user_id != NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_group_habit ON public.habit_records;
CREATE TRIGGER trigger_notify_group_habit
AFTER INSERT ON public.habit_records
FOR EACH ROW
WHEN (NEW.valor_progres > 0)
EXECUTE FUNCTION public.notify_group_habit_completed();

CREATE OR REPLACE FUNCTION public.send_end_of_day_reminder()
RETURNS void AS $$
BEGIN
    INSERT INTO public.notifications (receiver_id, type, created_at)
    SELECT id, 'end_of_day', NOW()
    FROM public.profiles
    WHERE fcm_token IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.send_habit_reminders()
RETURNS void AS $$
DECLARE
    v_current_time TEXT;
BEGIN
    v_current_time := to_char(NOW() AT TIME ZONE 'Europe/Madrid', 'HH24:MI');

    INSERT INTO public.notifications (receiver_id, type, habit_id, created_at)
    SELECT DISTINCT u.user_id_to_notify, 'habit_reminder', h.id, NOW()
    FROM public.habits h
    CROSS JOIN LATERAL (
        SELECT ph.user_id AS user_id_to_notify
        FROM public.participacions_habits ph
        WHERE ph.habit_grupal_id = h.id AND h.is_group = true
        UNION
        SELECT h.user_id AS user_id_to_notify
    ) u
    WHERE h.recordatoris = true
      AND h.arxivat = false
      AND v_current_time = ANY(h.hores_recordatori);
END;
$$ LANGUAGE plpgsql;

CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.unschedule('notificacio-final-dia');
SELECT cron.schedule('notificacio-final-dia', '0 20 * * *', 'SELECT public.send_end_of_day_reminder()');

SELECT cron.unschedule('notificacio-recordatoris-habits');
SELECT cron.schedule('notificacio-recordatoris-habits', '* * * * *', 'SELECT public.send_habit_reminders()');