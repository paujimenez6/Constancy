CREATE TABLE IF NOT EXISTS public.habits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    titol TEXT NOT NULL,
    descripcio TEXT,
    grup TEXT,
    icona TEXT NOT NULL,
    color TEXT NOT NULL,
    periode_objectiu TEXT NOT NULL DEFAULT 'diari',
    valor_objectiu NUMERIC NOT NULL DEFAULT 1,
    unitat_mesura TEXT NOT NULL DEFAULT 'vegades',
    ratxa_actual INTEGER DEFAULT 0,
    millor_ratxa INTEGER DEFAULT 0,
    data_inici DATE NOT NULL DEFAULT CURRENT_DATE,
    data_fi DATE,
    recordatoris BOOLEAN DEFAULT false,
    hores_recordatori TEXT[] DEFAULT '{}',
    arxivat BOOLEAN DEFAULT false,
    is_group BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.habit_records (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    data_registre DATE NOT NULL DEFAULT CURRENT_DATE,
    completat BOOLEAN DEFAULT false,
    valor_progres NUMERIC DEFAULT 0,
    comentari TEXT,
    is_shielded BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT habit_records_user_habit_date_unique UNIQUE(habit_id, user_id, data_registre)
);

ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_records ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuaris poden veure els seus propis hàbits" ON public.habits;
DROP POLICY IF EXISTS "Visibilitat d'hàbits" ON public.habits;
CREATE POLICY "Visibilitat d'hàbits" ON public.habits FOR SELECT USING (
  auth.uid() = user_id
  OR EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = habits.user_id
    AND profiles.configuracio_privacitat = 'public'
  )
  OR EXISTS (
    SELECT 1 FROM public.profiles p
    JOIN public.follows f ON f.following_id = habits.user_id
    WHERE p.id = habits.user_id
    AND p.configuracio_privacitat = 'amics'
    AND f.follower_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Usuaris poden crear els seus propis hàbits" ON public.habits;
CREATE POLICY "Usuaris poden crear els seus propis hàbits" ON public.habits FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuaris poden editar els seus propis hàbits" ON public.habits;
CREATE POLICY "Usuaris poden editar els seus propis hàbits" ON public.habits FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuaris poden esborrar els seus propis hàbits" ON public.habits;
CREATE POLICY "Usuaris poden esborrar els seus propis hàbits" ON public.habits FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuaris poden veure els seus registres" ON public.habit_records;
DROP POLICY IF EXISTS "Membres poden veure registres del grup" ON public.habit_records;
CREATE POLICY "Membres poden veure registres del grup" ON public.habit_records FOR SELECT USING (
  auth.uid() = user_id
  OR EXISTS (
    SELECT 1 FROM public.participacions_habits ph
    WHERE ph.habit_grupal_id = habit_records.habit_id
    AND ph.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Usuaris poden crear els seus registres" ON public.habit_records;
CREATE POLICY "Usuaris poden crear els seus registres" ON public.habit_records FOR INSERT WITH CHECK (
  auth.uid() = user_id AND (
    EXISTS (SELECT 1 FROM public.habits WHERE id = habit_id AND user_id = auth.uid()) OR
    EXISTS (SELECT 1 FROM public.participacions_habits WHERE habit_grupal_id = habit_id AND user_id = auth.uid())
  )
);

DROP POLICY IF EXISTS "Usuaris poden editar els seus registres" ON public.habit_records;
CREATE POLICY "Usuaris poden editar els seus registres" ON public.habit_records FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuaris poden esborrar els seus registres" ON public.habit_records;
CREATE POLICY "Usuaris poden esborrar els seus registres" ON public.habit_records FOR DELETE USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.cleanup_habit_records_on_date_change()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM public.habit_records
    WHERE habit_id = NEW.id
    AND (data_registre < NEW.data_inici OR (NEW.data_fi IS NOT NULL AND data_registre > NEW.data_fi));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_cleanup_habit_records ON public.habits;
CREATE TRIGGER trigger_cleanup_habit_records
BEFORE UPDATE ON public.habits
FOR EACH ROW EXECUTE FUNCTION public.cleanup_habit_records_on_date_change();

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

DROP TRIGGER IF EXISTS trigger_actualitzar_progres ON public.habit_records;
CREATE TRIGGER trigger_actualitzar_progres
AFTER INSERT OR UPDATE OR DELETE ON public.habit_records
FOR EACH ROW EXECUTE FUNCTION public.actualitzar_progres_acumulat();

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
            INSERT INTO public.habit_records (habit_id, user_id, data_registre, valor_progres, completat, is_shielded)
            VALUES (NEW.habit_id, v_user_id, NEW.data_registre, 0, (v_total_progres >= v_valor_objectiu), false)
            ON CONFLICT (habit_id, user_id, data_registre)
            DO UPDATE SET completat = (v_total_progres >= v_valor_objectiu);
        END LOOP;
    END IF;

    PERFORM public.recalcular_ratxa_habit(NEW.habit_id);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_sincronitzar_completat ON public.habit_records;
CREATE TRIGGER trigger_sincronitzar_completat
AFTER INSERT OR UPDATE OF valor_progres ON public.habit_records
FOR EACH ROW EXECUTE FUNCTION public.sincronitzar_completat_grupal();

CREATE OR REPLACE FUNCTION public.aplicar_protector_ratxa(p_user_id UUID, p_date DATE, p_inventory_id UUID)
RETURNS void AS $$
DECLARE
    v_quantitat INTEGER;
    v_habit_id UUID;
BEGIN
    SELECT quantitat INTO v_quantitat
    FROM public.user_inventory
    WHERE id = p_inventory_id AND user_id = p_user_id;

    IF v_quantitat IS NULL OR v_quantitat <= 0 THEN
        RAISE EXCEPTION 'No tens protectors de ratxa disponibles';
    END IF;

    UPDATE public.user_inventory
    SET quantitat = quantitat - 1
    WHERE id = p_inventory_id;

    FOR v_habit_id IN
        SELECT id FROM public.habits
        WHERE user_id = p_user_id AND arxivat = false
    LOOP
        INSERT INTO public.habit_records (habit_id, user_id, data_registre, valor_progres, completat, is_shielded)
        VALUES (v_habit_id, p_user_id, p_date, 0, true, true)
        ON CONFLICT (habit_id, user_id, data_registre)
        DO UPDATE SET is_shielded = true, completat = true, valor_progres = 0;
    END LOOP;

    PERFORM public.update_achievement_progress(p_user_id, 'utilitzarInventari25', 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;