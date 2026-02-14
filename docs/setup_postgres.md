# Local PostgreSQL Setup

This document describes how to set up a local PostgreSQL environment for this repository.

## Scope
**Covers**
- Installing PostgreSQL and `psql` locally.
- Provisioning the project role/user, database, and schema.
- Verifying the setup using SQL checks.

**Does NOT cover**
- Docker.
- Airflow.
- Cloud deployment.
- Production hardening.

## System Requirements
- OS: Ubuntu 24.04 (or compatible Debian-based distro).
- Tools: PostgreSQL server and `psql` client.

## Project Database Conventions
- DB user/role: `zain`
- Database name: `cde_foundation`
- Schema: `raw`
- Local secret env var: `LOCAL_DB_PASS` in `.env` (do not commit this file).

## Install PostgreSQL + psql (Ubuntu)
```bash
sudo apt update
sudo apt install -y postgresql postgresql-client
psql --version
```

Enable and start the service:

```bash
sudo systemctl enable --now postgresql
sudo systemctl status postgresql --no-pager
```

## Provisioning (Role + DB + Schema)
This repo keeps provisioning scripts under `scripts/`.

### A) Create or Update Role (run as postgres superuser)
Load your local password from `.env` and run the bootstrap script:

```bash
set -a
source .env
set +a

sudo -u postgres psql -v ON_ERROR_STOP=1 \
  -c "SET my.local_pass='$LOCAL_DB_PASS';" \
  -f scripts/00_bootstrap.sql
```

Notes:
- `scripts/00_bootstrap.sql` expects the session setting `my.local_pass`.
- The script is idempotent for role creation and always ensures `CREATEDB`.

### B) Create Database
```bash
sudo -u postgres createdb -O zain cde_foundation
```

### C) Initialize Schema (run as project user)
```bash
psql "postgresql://zain@localhost:5432/cde_foundation" \
  -v ON_ERROR_STOP=1 \
  -f scripts/01_init_schema.sql
```

## Verification
Run:

```bash
psql "postgresql://zain@localhost:5432/cde_foundation" \
  -c "SELECT current_user, current_database();"

psql "postgresql://zain@localhost:5432/cde_foundation" \
  -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name='raw';"
```

Expected:
- `current_user` is `zain`.
- `current_database` is `cde_foundation`.
- The schema query returns `raw`.

## Common Problems
1. Password prompts keep appearing.
- If you connect using a TCP URL (`postgresql://...`), you may be prompted for a password.
- Optional fix: configure `~/.pgpass` locally (never commit credentials).

2. "Role already exists" or "Database already exists".
- `scripts/00_bootstrap.sql` already handles role reruns safely.
- `createdb` is not idempotent; if the database already exists, skip this step.

3. Bootstrap script fails with `Missing session setting my.local_pass`.
- Ensure `.env` exists and exports `LOCAL_DB_PASS`.
- Ensure you run the `SET my.local_pass=...` command in the same `psql` invocation as `-f scripts/00_bootstrap.sql`.
