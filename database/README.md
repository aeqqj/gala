# Gala Database Project

This repository contains the core PostgreSQL database architecture for the Gala project. It is structured to be modular, idempotent, and secure for use within the Supabase environment.

## Directory Structure
- `01_schema.sql`: Table definitions, constraints, and relationships.
- `02_functions.sql`: Business logic, custom RPC functions, and event triggers.
- `03_policies.sql`: Row-Level Security (RLS) policies defining data access.
- `04_triggers.sql`: Database trigger registrations.

## Deployment Guidelines
To initialize or reset the database, execute the files in numerical order. All files are written with idempotency in mind (using `DROP IF EXISTS` and `CREATE OR REPLACE`), allowing for safe repeated deployments.

1. `01_schema.sql`
2. `02_functions.sql`
3. `03_policies.sql`
4. `04_triggers.sql`

## API Documentation (Custom RPC Functions)
These functions can be invoked from your frontend application using the Supabase client:
`supabase.rpc('function_name', { params })`

### `create_event`
- **Purpose**: Creates a new event record and automatically adds the organizer as an attendee.
- **Parameters**: 
    - `event_title` (text, **Required**)
    - `event_desc` (text, **Optional**)
    - `start_date` (timestamptz, **Required**)
    - `end_date` (timestamptz, **Required**)
    - `location_name` (text, **Optional**)
    - `google_place_id` (text, **Optional**, default: `NULL`)
    - `lat` (numeric, **Optional**, default: `NULL`)
    - `long` (numeric, **Optional**, default: `NULL`)
- **Returns**: `bigint` (The new `event_id`)

### `accept_event_invitation`
- **Purpose**: Updates an invitation status to 'accepted' and adds the user to the event's membership list.
- **Parameters**: `invite_id` (bigint)
- **Returns**: `void`

### `insert_friendship`
- **Purpose**: Creates a bidirectional friendship link between two users, automatically ordering user IDs to ensure data consistency.
- **Parameters**: `id1` (bigint), `id2` (bigint)
- **Returns**: `void`

## Security Hardening
- **Search Path**: All `SECURITY DEFINER` functions explicitly set `SET search_path = public` to protect against search-path injection attacks.
- **Atomic Transactions**: Complex operations like event creation and invitation acceptance are wrapped in SQL functions to ensure data integrity across multiple tables.
- **Row-Level Security (RLS)**: Access is strictly controlled via policies defined in `03_policies.sql`, ensuring users can only interact with data they are authorized to see or modify.
