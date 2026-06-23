-- ==========================================
-- GALA DATABASE FUNCTIONS
-- ==========================================

-- ==========================================
/*

   Use the following query to retrieve the
   names and definitionsof all functions you
   have created in the public schema.

SELECT 
    proname AS function_name, 
    pg_get_functiondef(p.oid) AS full_definition
FROM 
    pg_proc p
JOIN 
    pg_namespace n ON p.pronamespace = n.oid
WHERE 
    n.nspname = 'public';

*/
-- ==========================================



CREATE OR REPLACE FUNCTION public.insert_friendship(id1 bigint, id2 bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = public
AS $function$
BEGIN
    IF id1 < id2 THEN
        INSERT INTO public.user_friends (user_id_1, user_id_2) VALUES (id1, id2);
    ELSE
        INSERT INTO public.user_friends (user_id_1, user_id_2) VALUES (id2, id1);
    END IF;
END;
$function$



CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path = public
AS $function$
BEGIN
  INSERT INTO public.users (
    username, 
    first_name, 
    last_name, 
    user_email, 
    auth_id
  )
  VALUES (
    -- Now uses a guaranteed unique string: 'user_' + the user's UUID
    COALESCE(new.raw_user_meta_data->>'username', 'user_' || new.id::text),
    COALESCE(new.raw_user_meta_data->>'first_name', 'First'),
    COALESCE(new.raw_user_meta_data->>'last_name', 'Name'),
    new.email,
    new.id
  );
  RETURN new;
END;
$function$




CREATE OR REPLACE FUNCTION public.create_event(
    event_title text, 
    event_desc text, 
    start_date timestamp with time zone, 
    end_date timestamp with time zone, -- Added parameter
    location_name text
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
    new_event_id bigint;
BEGIN
    -- Guard: Prevent events that end before they start
    IF end_date < start_date THEN
        RAISE EXCEPTION 'End date cannot be before start date.';
    END IF;

    INSERT INTO public.events (
        event_title, 
        event_description, 
        start_timestamp, 
        end_timestamp, 
        event_status, 
        location_name, 
        organizer_id
    )
    VALUES (
        event_title, 
        event_desc, 
        start_date, 
        end_date, -- Use the provided end_date
        'scheduled', 
        location_name, 
        (SELECT user_id FROM public.users WHERE auth_id = auth.uid())
    )
    RETURNING event_id INTO new_event_id;

    INSERT INTO public.event_members (event_id, user_id, rsvp_status)
    VALUES (
        new_event_id, 
        (SELECT user_id FROM public.users WHERE auth_id = auth.uid()), 
        'attending'
    );

    RETURN new_event_id;
END;
$function$;



CREATE OR REPLACE FUNCTION public.accept_event_invitation(invite_id bigint)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    target_event_id bigint;
    target_recipient_id bigint;
BEGIN
    -- 1. Update the invitation status
    UPDATE public.event_invitations
    SET invitation_status = 'accepted'
    WHERE invitation_id = invite_id 
    AND recipient_id = (SELECT user_id FROM public.users WHERE auth_id = auth.uid())
    RETURNING event_id, recipient_id INTO target_event_id, target_recipient_id;

    -- 2. GUARD CLAUSE: Stop if no record was updated
    IF target_event_id IS NULL THEN
        RAISE EXCEPTION 'Invitation not found or you are not authorized to accept it.';
    END IF;

    -- 3. Insert into event_members
    INSERT INTO public.event_members (event_id, user_id, rsvp_status)
    VALUES (target_event_id, target_recipient_id, 'attending');
END;
$$;