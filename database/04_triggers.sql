-- ==========================================
-- GALA DATABASE TRIGGERS
-- ==========================================

-- ==========================================
/*

   Use the following query to view a comprehensive
   list of all custom triggers along with their
   activation conditions and definitions.

SELECT 
    event_object_schema AS table_schema, 
    event_object_table AS table_name, 
    trigger_name, 
    string_agg(event_manipulation, ',') AS event, 
    action_timing AS activation, 
    action_statement AS definition 
FROM 
    information_schema.triggers 
GROUP BY 
    1, 2, 3, 5, 6 
ORDER BY 
    table_schema, 
    table_name;



   Use the following query to
   retrieve trigger fefinition.

SELECT 
    tr.tgname AS trigger_name,
    pg_get_triggerdef(tr.oid) AS trigger_definition
FROM 
    pg_trigger tr
JOIN 
    pg_class cl ON tr.tgrelid = cl.oid
JOIN 
    pg_namespace ns ON cl.relnamespace = ns.oid
WHERE 
    tr.tgname = 'on_auth_user_created';

*/
-- ==========================================


-- Trigger: on_auth_user_created
-- Description: Syncs new Auth users to the public.users table.
-- Status: ACTIVE

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user()
