CREATE TABLE IF NOT EXISTS public.shop_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom_clau TEXT NOT NULL UNIQUE,
    desc_clau TEXT NOT NULL,
    tipus_efecte TEXT NOT NULL,
    valor_efecte FLOAT NOT NULL DEFAULT 1,
    preu INTEGER NOT NULL CHECK (preu >= 0),
    icona TEXT NOT NULL,
    actiu BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.user_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    item_id UUID REFERENCES public.shop_items(id) ON DELETE CASCADE,
    quantitat INTEGER NOT NULL DEFAULT 1 CHECK (quantitat >= 0),
    es_actiu BOOLEAN DEFAULT false,
    data_adquisicio TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, item_id)
);

ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_inventory ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Botiga visible per a tothom" ON public.shop_items FOR SELECT USING (true);
CREATE POLICY "Usuaris veuen el seu propi inventari" ON public.user_inventory FOR SELECT USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.comprar_objecte(p_item_id UUID, p_user_id UUID)
RETURNS void AS $$
DECLARE
    v_preu INTEGER;
    v_monedes_actuals INTEGER;
BEGIN
    SELECT preu INTO v_preu FROM public.shop_items WHERE id = p_item_id AND actiu = true;
    SELECT monedes INTO v_monedes_actuals FROM public.profiles WHERE id = p_user_id;

    IF v_preu IS NULL THEN RAISE EXCEPTION 'L''objecte no existeix o no està a la venda'; END IF;
    IF v_monedes_actuals < v_preu THEN RAISE EXCEPTION 'Saldo insuficient'; END IF;

    UPDATE public.profiles SET monedes = monedes - v_preu WHERE id = p_user_id;

    INSERT INTO public.user_inventory (user_id, item_id, quantitat)
    VALUES (p_user_id, p_item_id, 1)
    ON CONFLICT (user_id, item_id)
    DO UPDATE SET quantitat = public.user_inventory.quantitat + 1;

    PERFORM public.update_achievement_progress(p_user_id, 'compresBotiga25', 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.activar_multiplicador_xp(p_user_id UUID, p_inventory_id UUID)
RETURNS void AS $$
DECLARE
    v_quantitat INTEGER;
    v_fins TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT multiplicador_xp_fins INTO v_fins FROM public.profiles WHERE id = p_user_id;
    IF v_fins IS NOT NULL AND v_fins > NOW() THEN RAISE EXCEPTION 'Ja tens un multiplicador actiu'; END IF;

    SELECT quantitat INTO v_quantitat FROM public.user_inventory WHERE id = p_inventory_id AND user_id = p_user_id;
    IF v_quantitat <= 0 OR v_quantitat IS NULL THEN RAISE EXCEPTION 'No en tens cap'; END IF;

    UPDATE public.user_inventory SET quantitat = quantitat - 1 WHERE id = p_inventory_id;
    UPDATE public.profiles SET multiplicador_xp_fins = NOW() + INTERVAL '24 hours' WHERE id = p_user_id;

    PERFORM public.update_achievement_progress(p_user_id, 'utilitzarInventari25', 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.activar_imant_monedes(p_user_id UUID, p_inventory_id UUID)
RETURNS void AS $$
DECLARE
    v_quantitat INTEGER;
    v_fins TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT imant_monedes_fins INTO v_fins FROM public.profiles WHERE id = p_user_id;
    IF v_fins IS NOT NULL AND v_fins > NOW() THEN RAISE EXCEPTION 'Ja tens un imant actiu'; END IF;

    SELECT quantitat INTO v_quantitat FROM public.user_inventory WHERE id = p_inventory_id AND user_id = p_user_id;
    IF v_quantitat <= 0 OR v_quantitat IS NULL THEN RAISE EXCEPTION 'No en tens cap'; END IF;

    UPDATE public.user_inventory SET quantitat = quantitat - 1 WHERE id = p_inventory_id;
    UPDATE public.profiles SET imant_monedes_fins = NOW() + INTERVAL '12 hours' WHERE id = p_user_id;

    PERFORM public.update_achievement_progress(p_user_id, 'utilitzarInventari25', 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.aplicar_protector_ratxa(p_user_id UUID, p_date DATE, p_inventory_id UUID)
RETURNS void AS $$
DECLARE
    v_quantitat INTEGER;
    v_habit_id UUID;
BEGIN
    SELECT quantitat INTO v_quantitat FROM public.user_inventory WHERE id = p_inventory_id AND user_id = p_user_id;
    IF v_quantitat IS NULL OR v_quantitat <= 0 THEN RAISE EXCEPTION 'No tens protectors de ratxa disponibles'; END IF;

    UPDATE public.user_inventory SET quantitat = quantitat - 1 WHERE id = p_inventory_id;

    FOR v_habit_id IN SELECT id FROM public.habits WHERE user_id = p_user_id AND arxivat = false LOOP
        INSERT INTO public.habit_records (habit_id, user_id, data_registre, valor_progres, completat, is_shielded)
        VALUES (v_habit_id, p_user_id, p_date, 0, true, true)
        ON CONFLICT (habit_id, user_id, data_registre)
        DO UPDATE SET is_shielded = true, completat = true, valor_progres = 0;
    END LOOP;

    PERFORM public.update_achievement_progress(p_user_id, 'utilitzarInventari25', 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.reroll_missio(p_user_id UUID, p_user_mission_id UUID, p_inventory_id UUID)
RETURNS void AS $$
DECLARE
    v_quantitat INTEGER;
    v_nova_mission_id UUID;
    v_ids_actives UUID[];
BEGIN
    SELECT quantitat INTO v_quantitat FROM public.user_inventory WHERE id = p_inventory_id AND user_id = p_user_id;
    IF v_quantitat IS NULL OR v_quantitat <= 0 THEN RAISE EXCEPTION 'No tens rerolls disponibles'; END IF;

    SELECT array_agg(mission_id) INTO v_ids_actives FROM public.user_missions WHERE user_id = p_user_id AND data_assignada = CURRENT_DATE;

    SELECT id INTO v_nova_mission_id FROM public.missions_definicions WHERE id != ALL(v_ids_actives) ORDER BY random() LIMIT 1;
    IF v_nova_mission_id IS NULL THEN RAISE EXCEPTION 'No hi ha més missions disponibles per avui'; END IF;

    UPDATE public.user_inventory SET quantitat = quantitat - 1 WHERE id = p_inventory_id;

    DELETE FROM public.user_missions WHERE id = p_user_mission_id;
    INSERT INTO public.user_missions (user_id, mission_id, data_assignada, progres_actual, completada, reclamada)
    VALUES (p_user_id, v_nova_mission_id, CURRENT_DATE, 0, false, false);

    PERFORM public.update_achievement_progress(p_user_id, 'utilitzarInventari25', 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

INSERT INTO public.shop_items (nom_clau, desc_clau, tipus_efecte, valor_efecte, preu, icona)
VALUES
('item_streak_shield_title', 'item_streak_shield_desc', 'streak_shield', 1, 200, 'shield_rounded'),
('item_xp_multiplier_title', 'item_xp_multiplier_desc', 'xp_multiplier', 2, 100, 'bolt_rounded'),
('item_coin_magnet_title', 'item_coin_magnet_desc', 'coin_magnet', 2, 150, 'magnet_rounded'),
('item_mission_reroll_title', 'item_mission_reroll_desc', 'mission_reroll', 1, 50, 'refresh_rounded')
ON CONFLICT (nom_clau) DO NOTHING;