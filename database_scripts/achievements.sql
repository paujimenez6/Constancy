CREATE TABLE public.achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    icona TEXT NOT NULL,
    condicio_codi TEXT UNIQUE NOT NULL,
    valor_objectiu INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    achievement_id UUID REFERENCES public.achievements(id) ON DELETE CASCADE NOT NULL,
    progres_actual INTEGER DEFAULT 0 NOT NULL,
    completat BOOLEAN DEFAULT false NOT NULL,
    data_obtencio TIMESTAMPTZ,
    reclamat BOOLEAN DEFAULT false NOT NULL,
    UNIQUE(user_id, achievement_id)
);

CREATE TABLE public.user_perfect_days (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    data_registre DATE NOT NULL,
    PRIMARY KEY (user_id, data_registre)
);

CREATE OR REPLACE FUNCTION public.update_achievement_progress(
    p_user_id UUID,
    p_condicio_codi TEXT,
    p_increment INTEGER
)
RETURNS void AS $$
DECLARE
    v_ach_id UUID;
    v_obj INTEGER;
    v_actual INTEGER;
BEGIN
    SELECT id, valor_objectiu INTO v_ach_id, v_obj
    FROM public.achievements
    WHERE condicio_codi = p_condicio_codi;

    IF v_ach_id IS NOT NULL THEN
        INSERT INTO public.user_achievements (user_id, achievement_id, progres_actual)
        VALUES (p_user_id, v_ach_id, GREATEST(p_increment, 0))
        ON CONFLICT (user_id, achievement_id)
        DO UPDATE SET progres_actual = GREATEST(LEAST(public.user_achievements.progres_actual + p_increment, v_obj), 0);

        SELECT progres_actual INTO v_actual
        FROM public.user_achievements
        WHERE user_id = p_user_id AND achievement_id = v_ach_id;

        IF v_actual >= v_obj THEN
            UPDATE public.user_achievements
            SET completat = true,
                data_obtencio = COALESCE(data_obtencio, NOW())
            WHERE user_id = p_user_id AND achievement_id = v_ach_id;
        ELSE
            UPDATE public.user_achievements
            SET completat = false,
                data_obtencio = NULL
            WHERE user_id = p_user_id AND achievement_id = v_ach_id AND reclamat = false;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.increment_user_xp(p_user_id UUID, p_xp INTEGER)
RETURNS void AS $$
BEGIN
    UPDATE public.profiles
    SET punts_xp = COALESCE(punts_xp, 0) + p_xp
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.claim_achievement_reward(
    p_achievement_id UUID,
    p_user_id UUID,
    p_xp INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_completat BOOLEAN;
    v_reclamat BOOLEAN;
BEGIN
    SELECT completat, reclamat INTO v_completat, v_reclamat
    FROM public.user_achievements
    WHERE user_id = p_user_id AND achievement_id = p_achievement_id;

    IF v_completat = true AND (v_reclamat = false OR v_reclamat IS NULL) THEN
        UPDATE public.user_achievements
        SET reclamat = true
        WHERE user_id = p_user_id AND achievement_id = p_achievement_id;

        UPDATE public.profiles
        SET punts_xp = COALESCE(punts_xp, 0) + p_xp
        WHERE id = p_user_id;

        RETURN true;
    END IF;

    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.set_achievement_progress_absolute(
    p_user_id UUID,
    p_condicio_codi TEXT,
    p_value INTEGER
)
RETURNS void AS $$
DECLARE
    v_ach_id UUID;
    v_obj INTEGER;
    v_current INTEGER;
BEGIN
    SELECT id, valor_objectiu INTO v_ach_id, v_obj
    FROM public.achievements
    WHERE condicio_codi = p_condicio_codi;

    IF v_ach_id IS NOT NULL THEN
        SELECT progres_actual INTO v_current
        FROM public.user_achievements
        WHERE user_id = p_user_id AND achievement_id = v_ach_id;

        IF v_current IS NULL THEN
            v_current := 0;
        END IF;

        IF p_value > v_current THEN
            INSERT INTO public.user_achievements (user_id, achievement_id, progres_actual)
            VALUES (p_user_id, v_ach_id, LEAST(p_value, v_obj))
            ON CONFLICT (user_id, achievement_id)
            DO UPDATE SET progres_actual = LEAST(p_value, v_obj);
        END IF;

        IF p_value >= v_obj THEN
            UPDATE public.user_achievements
            SET completat = true,
                data_obtencio = COALESCE(data_obtencio, NOW())
            WHERE user_id = p_user_id AND achievement_id = v_ach_id;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.sincronitzar_assoliment_missions()
RETURNS TRIGGER AS $$
DECLARE
    v_count INTEGER;
    v_user_id UUID;
BEGIN
    v_user_id := COALESCE(NEW.user_id, OLD.user_id);

    SELECT count(*)::INTEGER INTO v_count
    FROM public.user_missions
    WHERE user_id = v_user_id AND completada = true;

    PERFORM public.set_achievement_progress_absolute(v_user_id, 'missionsCompletades50', v_count);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_sincronitzar_assoliment_missions
AFTER INSERT OR UPDATE OF completada OR DELETE ON public.user_missions
FOR EACH ROW
EXECUTE FUNCTION public.sincronitzar_assoliment_missions();

CREATE OR REPLACE FUNCTION public.sincronitzar_assoliment_lligues()
RETURNS TRIGGER AS $$
DECLARE
    v_nivell INTEGER;
BEGIN
    SELECT nivell_lliga INTO v_nivell
    FROM public.lligues
    WHERE id = NEW.league_id;

    IF v_nivell IS NOT NULL THEN
        IF v_nivell >= 3 THEN
            PERFORM public.set_achievement_progress_absolute(NEW.user_id, 'lligaOr', 1);
        END IF;
        IF v_nivell >= 6 THEN
            PERFORM public.set_achievement_progress_absolute(NEW.user_id, 'lligaDiamant', 1);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_sincronitzar_assoliment_lligues
AFTER INSERT OR UPDATE OF league_id ON public.participacio_lliga
FOR EACH ROW
EXECUTE FUNCTION public.sincronitzar_assoliment_lligues();

CREATE OR REPLACE FUNCTION public.sincronitzar_assoliment_foto_perfil()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.imatge_perfil IS NOT NULL AND NEW.imatge_perfil != '' THEN
        PERFORM public.set_achievement_progress_absolute(NEW.id, 'fotoPerfil', 1);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_sincronitzar_assoliment_foto_perfil
AFTER UPDATE OF imatge_perfil ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.sincronitzar_assoliment_foto_perfil();

CREATE OR REPLACE FUNCTION public.sincronitzar_assoliments_economics()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.punts_xp IS DISTINCT FROM OLD.punts_xp AND NEW.punts_xp IS NOT NULL THEN
        PERFORM public.set_achievement_progress_absolute(NEW.id, 'acumularXp1000', NEW.punts_xp);
    END IF;

    IF NEW.monedes IS DISTINCT FROM OLD.monedes AND NEW.monedes IS NOT NULL THEN
        PERFORM public.set_achievement_progress_absolute(NEW.id, 'acumularMonedes1000', NEW.monedes);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_sincronitzar_assoliments_economics
AFTER UPDATE OF punts_xp, monedes ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.sincronitzar_assoliments_economics();

CREATE OR REPLACE FUNCTION public.sincronitzar_dia_perfecte(
    p_user_id UUID,
    p_date DATE,
    p_is_perfect BOOLEAN
)
RETURNS void AS $$
DECLARE
    v_count INTEGER;
BEGIN
    IF p_is_perfect THEN
        INSERT INTO public.user_perfect_days (user_id, data_registre)
        VALUES (p_user_id, p_date)
        ON CONFLICT DO NOTHING;
    ELSE
        DELETE FROM public.user_perfect_days
        WHERE user_id = p_user_id AND data_registre = p_date;
    END IF;

    SELECT count(*)::INTEGER INTO v_count
    FROM public.user_perfect_days
    WHERE user_id = p_user_id;

    PERFORM public.set_achievement_progress_absolute(p_user_id, 'diaPerfecte10', v_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

INSERT INTO public.achievements (icona, condicio_codi, valor_objectiu)
VALUES
    ('edit_calendar', 'primerHabit', 1),
    ('check_circle_outline', 'completatHabits50', 50),
    ('whatshot', 'ratxa50', 50),
    ('groups', 'grupalsUnits5', 5),
    ('person_add', 'seguirAmics10', 10),
    ('assignment', 'missionsCompletades50', 50),
    ('storefront', 'compresBotiga25', 25),
    ('backpack', 'utilitzarInventari25', 25),
    ('military_tech', 'lligaOr', 1),
    ('diamond', 'lligaDiamant', 1),
    ('face', 'fotoPerfil', 1),
    ('phonelink_lock', 'activarMfa', 1),
    ('bolt', 'acumularXp1000', 1000),
    ('savings', 'acumularMonedes1000', 1000),
    ('auto_awesome', 'diaPerfecte10', 10);

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Permetre lectura pública d'assoliments" ON public.achievements;
CREATE POLICY "Permetre lectura pública d'assoliments" ON public.achievements FOR SELECT TO authenticated USING (true);

ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Visibilitat de progressos d'assoliments" ON public.user_achievements;
CREATE POLICY "Visibilitat de progressos d'assoliments" ON public.user_achievements FOR SELECT TO authenticated USING (
    auth.uid() = user_id
    OR EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = user_id AND profiles.configuracio_privacitat = 'public'
    )
);

ALTER TABLE public.user_perfect_days ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Usuaris veuen els seus propis dies perfectes" ON public.user_perfect_days;
CREATE POLICY "Usuaris veuen els seus propis dies perfectes" ON public.user_perfect_days FOR SELECT USING (auth.uid() = user_id);