-- One-time DEV-only cleanup for replacing fake seed data with real WD83AA data.
-- Run this only against the DEV Azure PostgreSQL Flexible Server when you are
-- intentionally clearing demo seed rows before the first WD83AA load.
--
-- This preserves schema and migrations. It deletes data from the current
-- application read-model tables and resets identity counters.

BEGIN;

TRUNCATE TABLE
    billet_occupants,
    billets,
    people,
    sections,
    organization_aliases,
    organizations
RESTART IDENTITY CASCADE;

COMMIT;

