CREATE TABLE IF NOT EXISTS public.missions_definicions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titol_clau TEXT NOT NULL UNIQUE,
    descripcio_clau TEXT NOT NULL,
    recompensa_xp INTEGER DEFAULT 0,
    recompensa_monedes INTEGER DEFAULT 0,
    objectiu FLOAT NOT NULL,
    tipus TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.user_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    mission_id UUID REFERENCES public.missions_definicions(id) ON DELETE CASCADE,
    progres_actual FLOAT DEFAULT 0,
    completada BOOLEAN DEFAULT false,
    data_assignada DATE DEFAULT CURRENT_DATE,
    reclamada BOOLEAN DEFAULT false,
    items_completats TEXT[] DEFAULT '{}',
    UNIQUE(user_id, mission_id, data_assignada)
);

ALTER TABLE public.missions_definicions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Missions visibles per a tothom" ON public.missions_definicions;
CREATE POLICY "Missions visibles per a tothom" ON public.missions_definicions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Usuaris veuen el seu propi progrés" ON public.user_missions;
CREATE POLICY "Usuaris veuen el seu propi progrés" ON public.user_missions FOR SELECT USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.assignar_missions_diaries(p_user_id UUID)
RETURNS void AS $$
BEGIN
    IF (SELECT count(*) FROM public.user_missions
        WHERE user_id = p_user_id AND data_assignada = CURRENT_DATE) < 3 THEN

        INSERT INTO public.user_missions (user_id, mission_id, data_assignada)
        SELECT p_user_id, id, CURRENT_DATE
        FROM public.missions_definicions
        ORDER BY random()
        LIMIT 3
        ON CONFLICT DO NOTHING;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.reclamar_recompensa_missio(p_user_mission_id UUID, p_user_id UUID)
RETURNS void AS $$
DECLARE
    v_xp INTEGER;
    v_monedes INTEGER;
    v_reclamada BOOLEAN;
    v_completada BOOLEAN;
    v_multi_xp_fins TIMESTAMP WITH TIME ZONE;
    v_imant_fins TIMESTAMP WITH TIME ZONE;
    v_xp_final INTEGER;
    v_monedes_finals INTEGER;
BEGIN
    SELECT
        m.recompensa_xp, m.recompensa_monedes, um.reclamada, um.completada,
        p.multiplicador_xp_fins, p.imant_monedes_fins
    INTO
        v_xp, v_monedes, v_reclamada, v_completada,
        v_multi_xp_fins, v_imant_fins
    FROM public.user_missions um
    JOIN public.missions_definicions m ON um.mission_id = m.id
    JOIN public.profiles p ON um.user_id = p.id
    WHERE um.id = p_user_mission_id AND um.user_id = p_user_id;

    IF v_reclamada THEN RAISE EXCEPTION 'Ja reclamada'; END IF;
    IF NOT v_completada THEN RAISE EXCEPTION 'No completada'; END IF;

    v_xp_final := CASE WHEN v_multi_xp_fins > NOW() THEN v_xp * 2 ELSE v_xp END;
    v_monedes_finals := CASE WHEN v_imant_fins > NOW() THEN v_monedes * 2 ELSE v_monedes END;

    UPDATE public.user_missions SET reclamada = true WHERE id = p_user_mission_id;

    UPDATE public.profiles
    SET punts_xp = punts_xp + v_xp_final,
        monedes = monedes + v_monedes_finals
    WHERE id = p_user_id;

    UPDATE public.participacio_lliga
    SET xp_temporada = xp_temporada + v_xp_final
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.incrementar_progres_missio(p_user_id UUID, p_tipus_missio TEXT, p_quantitat FLOAT, p_item_id TEXT)
RETURNS void AS $$
BEGIN
    UPDATE public.user_missions um
    SET
        progres_actual = LEAST(um.progres_actual + p_quantitat, md.objectiu),
        items_completats = array_append(um.items_completats, p_item_id),
        completada = CASE
            WHEN (um.progres_actual + p_quantitat) >= md.objectiu THEN true
            ELSE um.completada
        END
    FROM public.missions_definicions md
    WHERE um.mission_id = md.id
      AND um.user_id = p_user_id
      AND um.data_assignada = CURRENT_DATE
      AND md.tipus = p_tipus_missio
      AND um.completada = false
      AND NOT (p_item_id = ANY(um.items_completats));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.reroll_missio(p_user_id UUID, p_user_mission_id UUID, p_inventory_id UUID)
RETURNS void AS $$
DECLARE
    v_quantitat INTEGER;
    v_nova_mission_id UUID;
    v_ids_actives UUID[];
BEGIN
    SELECT quantitat INTO v_quantitat
    FROM public.user_inventory
    WHERE id = p_inventory_id AND user_id = p_user_id;

    IF v_quantitat IS NULL OR v_quantitat <= 0 THEN
        RAISE EXCEPTION 'No tens rerolls disponibles';
    END IF;

    SELECT array_agg(mission_id) INTO v_ids_actives
    FROM public.user_missions
    WHERE user_id = p_user_id AND data_assignada = CURRENT_DATE;

    SELECT id INTO v_nova_mission_id
    FROM public.missions_definicions
    WHERE id != ALL(COALESCE(v_ids_actives, '{}'::uuid[]))
    ORDER BY random()
    LIMIT 1;

    IF v_nova_mission_id IS NULL THEN
        RAISE EXCEPTION 'No hi ha més missions disponibles per avui';
    END IF;

    UPDATE public.user_inventory
    SET quantitat = quantitat - 1
    WHERE id = p_inventory_id;

    DELETE FROM public.user_missions WHERE id = p_user_mission_id;

    INSERT INTO public.user_missions (user_id, mission_id, data_assignada, progres_actual, completada, reclamada)
    VALUES (p_user_id, v_nova_mission_id, CURRENT_DATE, 0, false, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

INSERT INTO public.missions_definicions (titol_clau, descripcio_clau, recompensa_xp, recompensa_monedes, objectiu, tipus)
VALUES
('mission_habits_title', 'mission_habits_desc', 50, 10, 3, 'habits'),
('mission_social_title', 'mission_social_desc', 30, 5, 1, 'social'),
('mission_xp_title', 'mission_xp_desc', 100, 20, 500, 'xp'),
('mission_complete_title', 'mission_complete_desc', 40, 10, 5, 'habits'),
('mission_top_league_title', 'mission_top_league_desc', 80, 25, 3, 'league'),
('mission_perfect_day_title', 'mission_perfect_day_desc', 120, 40, 1, 'perfect_day'),
('mission_avg_progress_title', 'mission_avg_progress_desc', 60, 15, 80, 'stats'),
('mission_shop_buy_title', 'mission_shop_buy_desc', 25, 15, 1, 'shop_buy'),
('mission_inventory_use_title', 'mission_inventory_use_desc', 20, 10, 1, 'inventory_use')
ON CONFLICT (titol_clau) DO UPDATE SET
    descripcio_clau = EXCLUDED.descripcio_clau,
    recompensa_xp = EXCLUDED.recompensa_xp,
    recompensa_monedes = EXCLUDED.recompensa_monedes,
    objectiu = EXCLUDED.objectiu,
    tipus = EXCLUDED.tipus;