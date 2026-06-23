-- ==========================================
-- GALA APP SECURITY POLICIES
-- ==========================================

-- ==========================================
/*

   Use the following query to extract and
   reconstruct all existing RLS policy definitions
   from the Supabase database into executable
   CREATE POLICY SQL statements.

SELECT 
    'CREATE POLICY "' || polname || '" ON ' || relname || 
    ' FOR ' || 
    CASE 
        WHEN polcmd = 'r' THEN 'SELECT'
        WHEN polcmd = 'w' THEN 'UPDATE'
        WHEN polcmd = 'a' THEN 'INSERT'
        WHEN polcmd = 'd' THEN 'DELETE'
        ELSE 'ALL'
    END || 
    ' TO authenticated USING (' || pg_get_expr(polqual, polrelid) || ')' ||
    CASE 
        WHEN polwithcheck IS NOT NULL THEN ' WITH CHECK (' || pg_get_expr(polwithcheck, polrelid) || ');'
        ELSE ';'
    END AS sql_definition
FROM pg_policy
JOIN pg_class ON pg_policy.polrelid = pg_class.oid
WHERE pg_class.relkind = 'r';

*/
-- ==========================================


-- ------------------------------------------
-- 1. USERS TABLE
-- ------------------------------------------

-- Public profiles viewable by everyone
DROP POLICY IF EXISTS "Public profiles viewable by everyone" ON public.users;
CREATE POLICY "Public profiles viewable by everyone" ON users FOR SELECT TO authenticated USING (true);

-- Users can update their own profile
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
CREATE POLICY "Users can update their own profile" ON users FOR UPDATE TO authenticated USING ((auth.uid() = auth_id));


-- ------------------------------------------
-- 2. EVENTS TABLE
-- ------------------------------------------

-- Events are restricted to participants
DROP POLICY IF EXISTS "Events are restricted to participants" ON public.events;
CREATE POLICY "Events are restricted to participants" ON events FOR SELECT TO authenticated USING (((auth.uid() = ( SELECT users.auth_id
   FROM users
  WHERE (users.user_id = events.organizer_id))) OR (auth.uid() IN ( SELECT u.auth_id
   FROM (event_members em
     JOIN users u ON ((em.user_id = u.user_id)))
  WHERE (em.event_id = events.event_id))) OR (auth.uid() IN ( SELECT u.auth_id
   FROM (event_invitations ei
     JOIN users u ON ((ei.recipient_id = u.user_id)))
  WHERE (ei.event_id = events.event_id)))));

-- Organizers can manage their own events
DROP POLICY IF EXISTS "Organizers can manage their own events" ON public.events;
CREATE POLICY "Organizers can manage their own events" ON events FOR ALL TO authenticated USING ((auth.uid() = ( SELECT users.auth_id
   FROM users
  WHERE (users.user_id = events.organizer_id))));


-- ------------------------------------------
-- 3. EVENT MEMBERS & INVITATIONS
-- ------------------------------------------

-- Members can view participants
DROP POLICY IF EXISTS "Members can view participants" ON event_members;
CREATE POLICY "Members can view participants" ON event_members FOR SELECT TO authenticated USING (true);

-- Participants can view their invites
DROP POLICY IF EXISTS "Participants can view their invites" ON event_invitations;
CREATE POLICY "Participants can view their invites" ON event_invitations FOR SELECT TO authenticated USING (((auth.uid() = ( SELECT users.auth_id
   FROM users
  WHERE (users.user_id = event_invitations.sender_id))) OR (auth.uid() = ( SELECT users.auth_id
   FROM users
  WHERE (users.user_id = event_invitations.recipient_id)))));


-- ------------------------------------------
-- 4. FRIENDS & CREDENTIALS
-- ------------------------------------------

-- Users can view their own friendships
DROP POLICY IF EXISTS "Users can view their own friendships" ON user_friends;
CREATE POLICY "Users can view their own friendships" ON user_friends FOR SELECT TO authenticated USING (((auth.uid() = ( SELECT users.auth_id
   FROM users
  WHERE (users.user_id = user_friends.user_id_1))) OR (auth.uid() = ( SELECT users.auth_id
   FROM users
  WHERE (users.user_id = user_friends.user_id_2)))));