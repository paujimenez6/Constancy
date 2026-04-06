CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
  nickname TEXT UNIQUE NOT NULL,
  nom TEXT,
  cognom TEXT,
  correu TEXT UNIQUE,
  imatge_perfil TEXT,
  punts_xp INTEGER DEFAULT 0,
  nivell_xp INTEGER DEFAULT 1,
  monedes INTEGER DEFAULT 0,
  configuracio_privacitat TEXT DEFAULT 'public',
  data_registre TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Perfils visibles per a tothom" ON public.profiles;
CREATE POLICY "Perfils visibles per a tothom"
ON public.profiles FOR SELECT USING ( true );

DROP POLICY IF EXISTS "Usuaris poden crear el seu propi perfil" ON public.profiles;
CREATE POLICY "Usuaris poden crear el seu propi perfil"
ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Usuaris poden editar el seu propi perfil" ON public.profiles;
CREATE POLICY "Usuaris poden editar el seu propi perfil"
ON public.profiles FOR UPDATE USING ( auth.uid() = id );

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
    nivell_xp,
    monedes,
    configuracio_privacitat
  )
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'nickname', 'user_' || substring(new.id::text, 1, 5)),
    new.raw_user_meta_data->>'nom',
    new.raw_user_meta_data->>'cognom',
    new.email,
    0, 1, 0, 'public'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();