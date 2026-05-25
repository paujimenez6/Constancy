CREATE TABLE IF NOT EXISTS public.follows (
    follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower ON public.follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON public.follows(following_id);

CREATE TABLE IF NOT EXISTS public.follow_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(sender_id, receiver_id)
);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follow_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Tothom pot veure els seguidors" ON public.follows;
CREATE POLICY "Tothom pot veure els seguidors" ON public.follows FOR SELECT USING (true);

DROP POLICY IF EXISTS "Permetre seguir o acceptar seguidors" ON public.follows;
CREATE POLICY "Permetre seguir o acceptar seguidors" ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id OR auth.uid() = following_id);

DROP POLICY IF EXISTS "Propietari o seguidor poden esborrar la relació" ON public.follows;
CREATE POLICY "Propietari o seguidor poden esborrar la relació" ON public.follows FOR DELETE USING (auth.uid() = follower_id OR auth.uid() = following_id);

DROP POLICY IF EXISTS "Els usuaris poden enviar sol·licituds" ON public.follow_requests;
CREATE POLICY "Els usuaris poden enviar sol·licituds" ON public.follow_requests FOR INSERT WITH CHECK (auth.uid() = sender_id);

DROP POLICY IF EXISTS "Els usuaris poden veure les seves sol·licituds" ON public.follow_requests;
CREATE POLICY "Els usuaris poden veure les seves sol·licituds" ON public.follow_requests FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

DROP POLICY IF EXISTS "Els usuaris poden esborrar sol·licituds pròpies o rebudes" ON public.follow_requests;
CREATE POLICY "Els usuaris poden esborrar sol·licituds pròpies o rebudes" ON public.follow_requests FOR DELETE USING (auth.uid() = sender_id OR auth.uid() = receiver_id);