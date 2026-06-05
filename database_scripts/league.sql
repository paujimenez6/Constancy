DROP TRIGGER IF EXISTS trigger_recalcul_posicions ON participacio_lliga;
DROP TRIGGER IF EXISTS trigger_nou_usuari_lliga ON profiles;

DROP TABLE IF EXISTS resultats_lliga;
DROP TABLE IF EXISTS participacio_lliga;
DROP TABLE IF EXISTS lligues;
DROP TABLE IF EXISTS lligues_definicions;

CREATE TABLE lligues_definicions (
    nivell INTEGER PRIMARY KEY,
    nom TEXT NOT NULL,
    color TEXT NOT NULL
);

INSERT INTO lligues_definicions (nivell, nom, color) VALUES
(1, 'Bronze', '#CD7F32'),
(2, 'Plata', '#C0C0C0'),
(3, 'Or', '#FFD700'),
(4, 'Rubí', '#E0115F'),
(5, 'Esmeralda', '#50C878'),
(6, 'Diamant', '#B9F2FF');

CREATE TABLE lligues (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nivell_lliga INTEGER REFERENCES lligues_definicions(nivell) NOT NULL,
    nom_lliga TEXT NOT NULL,
    color TEXT NOT NULL,
    data_inici TIMESTAMPTZ NOT NULL,
    data_fi TIMESTAMPTZ NOT NULL,
    activa BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE participacio_lliga (
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    league_id UUID REFERENCES lligues(id) ON DELETE CASCADE NOT NULL,
    xp_temporada INTEGER DEFAULT 0,
    posicio_actual INTEGER DEFAULT 1,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, league_id)
);

CREATE TABLE resultats_lliga (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    nivell_anterior INTEGER NOT NULL,
    nivell_nou INTEGER NOT NULL,
    posicio_final INTEGER NOT NULL,
    vists BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION public.obtenir_lliga_disponible(p_nivell INTEGER)
RETURNS UUID AS $$
DECLARE
    v_league_id UUID;
    v_start TIMESTAMPTZ := date_trunc('week', now());
    v_end TIMESTAMPTZ := v_start + interval '7 days';
BEGIN
    SELECT l.id INTO v_league_id
    FROM public.lligues l
    LEFT JOIN public.participacio_lliga p ON l.id = p.league_id
    WHERE l.nivell_lliga = p_nivell AND l.activa = true
    GROUP BY l.id
    HAVING count(p.user_id) < 10
    LIMIT 1;

    IF v_league_id IS NULL THEN
        INSERT INTO public.lligues (nivell_lliga, nom_lliga, color, data_inici, data_fi)
        SELECT nivell, nom, color, v_start, v_end
        FROM public.lligues_definicions WHERE nivell = p_nivell
        RETURNING id INTO v_league_id;
    END IF;

    RETURN v_league_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.actualitzar_posicions_lliga()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.participacio_lliga
    SET posicio_actual = sub.nova_posicio
    FROM (
        SELECT user_id, league_id,
               ROW_NUMBER() OVER (PARTITION BY league_id ORDER BY xp_temporada DESC, joined_at ASC) as nova_posicio
        FROM public.participacio_lliga
        WHERE league_id = NEW.league_id
    ) AS sub
    WHERE public.participacio_lliga.user_id = sub.user_id AND public.participacio_lliga.league_id = sub.league_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_recalcul_posicions
AFTER UPDATE OF xp_temporada ON participacio_lliga
FOR EACH ROW EXECUTE FUNCTION actualitzar_posicions_lliga();

CREATE OR REPLACE FUNCTION public.assignar_lliga_inicial()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.participacio_lliga (user_id, league_id, xp_temporada, posicio_actual)
    VALUES (NEW.id, public.obtenir_lliga_disponible(1), 0, 1);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_nou_usuari_lliga
AFTER INSERT ON profiles
FOR EACH ROW EXECUTE FUNCTION assignar_lliga_inicial();

CREATE OR REPLACE FUNCTION public.rotacio_setmanal_lligues()
RETURNS void AS $$
DECLARE
    curr RECORD;
    v_target_level INTEGER;
    v_new_league_id UUID;
BEGIN
    UPDATE public.lligues SET activa = false WHERE activa = true;

    FOR curr IN
        SELECT p.*, l.nivell_lliga
        FROM public.participacio_lliga p
        JOIN public.lligues l ON p.league_id = l.id
        WHERE l.activa = false
    LOOP
        v_target_level := CASE
            WHEN curr.posicio_actual <= 3 AND curr.nivell_lliga < 6 THEN curr.nivell_lliga + 1
            WHEN curr.posicio_actual >= 8 AND curr.nivell_lliga > 1 THEN curr.nivell_lliga - 1
            ELSE curr.nivell_lliga
        END;

        INSERT INTO public.resultats_lliga (user_id, nivell_anterior, nivell_nou, posicio_final)
        VALUES (curr.user_id, curr.nivell_lliga, v_target_level, curr.posicio_actual);

        INSERT INTO public.notifications (receiver_id, type, created_at)
        VALUES (curr.user_id, 'league_end', NOW());

        v_new_league_id := public.obtenir_lliga_disponible(v_target_level);

        DELETE FROM public.participacio_lliga WHERE user_id = curr.user_id AND league_id = curr.league_id;

        INSERT INTO public.participacio_lliga (user_id, league_id, xp_temporada, posicio_actual)
        VALUES (curr.user_id, v_new_league_id, 0, 1);
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

ALTER TABLE lligues ENABLE ROW LEVEL SECURITY;
ALTER TABLE participacio_lliga ENABLE ROW LEVEL SECURITY;
ALTER TABLE resultats_lliga ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública lligues" ON lligues FOR SELECT USING (true);
CREATE POLICY "Lectura pública rànquings" ON participacio_lliga FOR SELECT USING (true);
CREATE POLICY "Usuaris veuen els seus resultats" ON resultats_lliga FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuaris marquen com vists" ON resultats_lliga FOR UPDATE USING (auth.uid() = user_id);

ALTER PUBLICATION supabase_realtime ADD TABLE participacio_lliga;

INSERT INTO participacio_lliga (user_id, league_id, xp_temporada, posicio_actual)
SELECT p.id, obtenir_lliga_disponible(1), 0, 1
FROM profiles p
WHERE NOT EXISTS (SELECT 1 FROM participacio_lliga pl WHERE pl.user_id = p.id);