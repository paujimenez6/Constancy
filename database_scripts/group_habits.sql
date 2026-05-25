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