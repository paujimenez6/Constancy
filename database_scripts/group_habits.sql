CREATE TABLE IF NOT EXISTS public.group_habits (
    id UUID PRIMARY KEY REFERENCES public.habits(id) ON DELETE CASCADE,
    codi_invitacio TEXT UNIQUE NOT NULL,
    creat_per UUID REFERENCES public.profiles(id)
);

CREATE TABLE IF NOT EXISTS public.participacions_habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    habit_grupal_id UUID REFERENCES public.group_habits(id) ON DELETE CASCADE,
    data_inscripcio TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    es_administrador BOOLEAN DEFAULT false,
    progres_acumulat FLOAT DEFAULT 0,
    UNIQUE(user_id, habit_grupal_id)
);

CREATE OR REPLACE FUNCTION public.unir_a_habit_grupal(p_user_id UUID, p_codi TEXT)
RETURNS void AS $$
DECLARE
    v_habit_id UUID;
BEGIN
    SELECT id INTO v_habit_id FROM public.group_habits WHERE codi_invitacio = p_codi;

    IF v_habit_id IS NULL THEN
        RAISE EXCEPTION 'Codi d''invitació no vàlid';
    END IF;

    INSERT INTO public.participacions_habits (user_id, habit_grupal_id, es_administrador)
    VALUES (p_user_id, v_habit_id, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.actualitzar_progres_acumulat()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.group_habits WHERE id = COALESCE(NEW.habit_id, OLD.habit_id)) THEN
        UPDATE public.participacions_habits
        SET progres_acumulat = (
            SELECT COALESCE(SUM(valor_progres), 0)
            FROM public.habit_records
            WHERE habit_id = COALESCE(NEW.habit_id, OLD.habit_id)
            AND user_id = COALESCE(NEW.user_id, OLD.user_id)
        )
        WHERE habit_grupal_id = COALESCE(NEW.habit_id, OLD.habit_id)
        AND user_id = COALESCE(NEW.user_id, OLD.user_id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.recalcular_ratxa_habit(p_habit_id UUID)
RETURNS void AS $$
DECLARE
    v_periode TEXT;
    v_objectiu NUMERIC;
    v_ratxa_actual INTEGER := 0;
    v_millor_ratxa INTEGER := 0;
    v_data_actual DATE := CURRENT_DATE;
    v_progres_dia NUMERIC;
BEGIN
    SELECT periode_objectiu, valor_objectiu, millor_ratxa
    INTO v_periode, v_objectiu, v_millor_ratxa
    FROM public.habits WHERE id = p_habit_id;

    LOOP
        SELECT COALESCE(SUM(valor_progres), 0) INTO v_progres_dia
        FROM public.habit_records
        WHERE habit_id = p_habit_id AND data_registre = v_data_actual;

        IF v_progres_dia >= v_objectiu THEN
            v_ratxa_actual := v_ratxa_actual + 1;
            IF v_periode = 'diari' THEN v_data_actual := v_data_actual - 1;
            ELSIF v_periode = 'setmanal' THEN v_data_actual := v_data_actual - 7;
            ELSE v_data_actual := v_data_actual - 30;
            END IF;
        ELSE
            IF v_data_actual = CURRENT_DATE THEN
                IF v_periode = 'diari' THEN v_data_actual := v_data_actual - 1;
                ELSIF v_periode = 'setmanal' THEN v_data_actual := v_data_actual - 7;
                ELSE v_data_actual := v_data_actual - 30;
                END IF;
                CONTINUE;
            END IF;
            EXIT;
        END IF;
    END LOOP;

    IF v_ratxa_actual > v_millor_ratxa THEN
        v_millor_ratxa := v_ratxa_actual;
    END IF;

    UPDATE public.habits
    SET ratxa_actual = v_ratxa_actual, millor_ratxa = v_millor_ratxa
    WHERE id = p_habit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.sincronitzar_completat_grupal()
RETURNS TRIGGER AS $$
DECLARE
    v_valor_objectiu NUMERIC;
    v_total_progres NUMERIC;
    v_is_group BOOLEAN;
    v_user_id UUID;
BEGIN
    SELECT is_group, valor_objectiu INTO v_is_group, v_valor_objectiu
    FROM public.habits WHERE id = NEW.habit_id;

    IF v_is_group THEN
        SELECT COALESCE(SUM(valor_progres), 0) INTO v_total_progres
        FROM public.habit_records
        WHERE habit_id = NEW.habit_id AND data_registre = NEW.data_registre;

        FOR v_user_id IN
            SELECT user_id FROM public.participacions_habits WHERE habit_grupal_id = NEW.habit_id
        LOOP
            INSERT INTO public.habit_records (habit_id, user_id, data_registre, valor_progres, completat)
            VALUES (NEW.habit_id, v_user_id, NEW.data_registre, 0, (v_total_progres >= v_valor_objectiu))
            ON CONFLICT (habit_id, user_id, data_registre)
            DO UPDATE SET completat = (v_total_progres >= v_valor_objectiu);
        END LOOP;
    END IF;

    PERFORM public.recalcular_ratxa_habit(NEW.habit_id);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_actualitzar_progres ON public.habit_records;
CREATE TRIGGER trigger_actualitzar_progres
AFTER INSERT OR UPDATE OR DELETE ON public.habit_records
FOR EACH ROW
EXECUTE FUNCTION public.actualitzar_progres_acumulat();

DROP TRIGGER IF EXISTS trigger_sincronitzar_completat ON public.habit_records;
CREATE TRIGGER trigger_sincronitzar_completat
AFTER INSERT OR UPDATE OF valor_progres ON public.habit_records
FOR EACH ROW
EXECUTE FUNCTION public.sincronitzar_completat_grupal();

CREATE OR REPLACE VIEW public.v_user_habits
WITH (security_invoker = true) AS
SELECT DISTINCT h.*, ph.user_id as participant_id
FROM public.habits h
LEFT JOIN public.participacions_habits ph ON h.id = ph.habit_grupal_id;

CREATE OR REPLACE VIEW public.v_habit_group_ranking AS
SELECT
    ph.habit_grupal_id,
    ph.user_id,
    ph.progres_acumulat,
    ph.es_administrador,
    p.nickname,
    p.imatge_perfil,
    COALESCE(
        (SELECT hr.valor_progres
         FROM public.habit_records hr
         WHERE hr.user_id = ph.user_id
           AND hr.habit_id = ph.habit_grupal_id
           AND hr.data_registre = CURRENT_DATE
         LIMIT 1),
    0) AS progres_avui
FROM public.participacions_habits ph
JOIN public.profiles p ON ph.user_id = p.id;

CREATE OR REPLACE FUNCTION public.get_group_ranking_custom_date(p_habit_id UUID, p_date DATE)
RETURNS TABLE (
    user_id UUID,
    nickname TEXT,
    imatge_perfil TEXT,
    progres_acumulat FLOAT,
    es_administrador BOOLEAN,
    progres_dia FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ph.user_id,
        p.nickname,
        p.imatge_perfil,
        ph.progres_acumulat,
        ph.es_administrador,
        COALESCE(
            (SELECT hr.valor_progres
             FROM public.habit_records hr
             WHERE hr.user_id = ph.user_id
               AND hr.habit_id = ph.habit_grupal_id
               AND hr.data_registre = p_date
             LIMIT 1),
        0)::FLOAT AS progres_dia
    FROM public.participacions_habits ph
    JOIN public.profiles p ON ph.user_id = p.id
    WHERE ph.habit_grupal_id = p_habit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.get_group_total_progress(p_habit_id UUID, p_date DATE)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(valor_progres), 0)
        FROM public.habit_records
        WHERE habit_id = p_habit_id AND data_registre = p_date
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

ALTER TABLE public.group_habits ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Usuaris poden crear els seus propis hàbits grupals" ON public.group_habits;
CREATE POLICY "Usuaris poden crear els seus propis hàbits grupals" ON public.group_habits FOR INSERT TO authenticated WITH CHECK (auth.uid() = creat_per);
DROP POLICY IF EXISTS "Usuaris poden veure hàbits grupals" ON public.group_habits;
CREATE POLICY "Usuaris poden veure hàbits grupals" ON public.group_habits FOR SELECT TO authenticated USING (true);

ALTER TABLE public.participacions_habits ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Usuaris poden crear la seva pròpia participació" ON public.participacions_habits;
CREATE POLICY "Usuaris poden crear la seva pròpia participació" ON public.participacions_habits FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Usuaris poden veure participacions" ON public.participacions_habits;
CREATE POLICY "Usuaris poden veure participacions" ON public.participacions_habits FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Usuaris poden actualitzar el seu propi progrés" ON public.participacions_habits;
CREATE POLICY "Usuaris poden actualitzar el seu propi progrés" ON public.participacions_habits FOR UPDATE TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Usuaris poden eliminar la seva pròpia participació" ON public.participacions_habits;
CREATE POLICY "Usuaris poden eliminar la seva pròpia participació" ON public.participacions_habits FOR DELETE TO authenticated USING (auth.uid() = user_id);

ALTER PUBLICATION supabase_realtime ADD TABLE public.participacions_habits;
ALTER PUBLICATION supabase_realtime ADD TABLE public.habit_records;

DROP POLICY IF EXISTS "Usuaris poden eliminar els seus propis hàbits grupals" ON public.group_habits;
CREATE POLICY "Usuaris poden eliminar els seus propis hàbits grupals"
ON public.group_habits FOR DELETE USING (auth.uid() = creat_per);

DROP POLICY IF EXISTS "Usuaris poden eliminar participacions" ON public.participacions_habits;
DROP POLICY IF EXISTS "Usuaris poden eliminar la seva pròpia participació" ON public.participacions_habits;
CREATE POLICY "Usuaris poden eliminar participacions"
ON public.participacions_habits FOR DELETE USING (
  auth.uid() = user_id
  OR EXISTS (SELECT 1 FROM public.habits WHERE id = habit_grupal_id AND user_id = auth.uid())
);

DROP POLICY IF EXISTS "Usuaris poden esborrar els seus registres" ON public.habit_records;
CREATE POLICY "Usuaris poden esborrar els seus registres"
ON public.habit_records FOR DELETE USING (
  auth.uid() = user_id
  OR EXISTS (SELECT 1 FROM public.habits WHERE id = habit_id AND user_id = auth.uid())
);

ALTER TABLE public.group_habits
DROP CONSTRAINT IF EXISTS group_habits_creat_per_fkey;

ALTER TABLE public.group_habits
ADD CONSTRAINT group_habits_creat_per_fkey
FOREIGN KEY (creat_per)
REFERENCES public.profiles(id)
ON DELETE CASCADE;