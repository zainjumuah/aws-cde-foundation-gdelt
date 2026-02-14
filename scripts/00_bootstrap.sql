-- scripts/00_bootstrap.sql
-- Run as postgres superuser

DO $$
DECLARE
  pwd text := current_setting('my.local_pass', true);
BEGIN
  IF pwd IS NULL OR length(pwd) = 0 THEN
    RAISE EXCEPTION 'Missing session setting my.local_pass';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'zain') THEN
    EXECUTE format('CREATE ROLE zain LOGIN PASSWORD %L', pwd);
  ELSE
    -- keep password in sync for when I rerun
    EXECUTE format('ALTER ROLE zain PASSWORD %L', pwd);
  END IF;
END $$;

-- Make sure privileges are correct regardless of whether the role existed already
ALTER ROLE zain CREATEDB;
