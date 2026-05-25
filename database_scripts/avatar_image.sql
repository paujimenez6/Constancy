INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Avatar públic per a tothom" ON storage.objects;
DROP POLICY IF EXISTS "Usuaris poden pujar el seu propi avatar" ON storage.objects;
DROP POLICY IF EXISTS "Usuaris poden actualitzar el seu propi avatar" ON storage.objects;
DROP POLICY IF EXISTS "Usuaris poden esborrar el seu propi avatar" ON storage.objects;

CREATE POLICY "Avatar públic per a tothom"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

CREATE POLICY "Usuaris poden pujar el seu propi avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Usuaris poden actualitzar el seu propi avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Usuaris poden esborrar el seu propi avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE OR REPLACE FUNCTION public.delete_user_avatar_folder()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM storage.objects
  WHERE bucket_id = 'avatars'
  AND (storage.foldername(name))[1] = OLD.id::text;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_delete_avatar_on_profile_delete ON public.profiles;

CREATE TRIGGER trigger_delete_avatar_on_profile_delete
  AFTER DELETE ON public.profiles
  FOR EACH ROW
  EXECUTE PROCEDURE public.delete_user_avatar_folder();