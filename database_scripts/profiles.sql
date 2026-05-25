CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
    nickname text UNIQUE NOT NULL,
    nom text,
    cognom text,
    correu text UNIQUE,
    imatge_perfil text,
    punts_xp integer DEFAULT 0,
    monedes integer DEFAULT 0,
    configuracio_privacitat text DEFAULT 'privat',
    data_registre timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    doble_factor_actiu boolean DEFAULT false,
    multiplicador_xp_fins timestamp with time zone,
    imant_monedes_fins timestamp with time zone,
    fcm_token text,
    locale text DEFAULT 'ca'
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Perfils visibles per a tothom" ON public.profiles;
CREATE POLICY "Perfils visibles per a tothom" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Usuaris poden editar el seu propi perfil" ON public.profiles;
CREATE POLICY "Usuaris poden editar el seu propi perfil" ON public.profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Els usuaris poden crear el seu propi perfil" ON public.profiles;
CREATE POLICY "Els usuaris poden crear el seu propi perfil" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    nickname,
    nom,
    cognom,
    correu,
    punts_xp,
    monedes,
    configuracio_privacitat
  )
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'nickname', 'user_' || substring(new.id::text, 1, 5)),
    new.raw_user_meta_data->>'nom',
    new.raw_user_meta_data->>'cognom',
    new.email,
    0,
    0,
    'privat'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

CREATE OR REPLACE FUNCTION public.delete_current_user()
RETURNS void AS $$
BEGIN
  DELETE FROM public.profiles WHERE id = auth.uid();
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;