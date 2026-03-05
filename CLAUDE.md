# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Odoo development environment (devcontainer) that runs inside Docker. The workspace root is `/work`. Odoo itself lives in `src/community` (community edition) and optionally `src/enterprise` (enterprise edition). Custom/extra addons go in `src/extra-addons/`.

## Running Odoo

The primary way to start Odoo is via the VSCode launch configurations (`F5`), or directly from the terminal:

```sh
# Start server (port 8069, all addons)
src/community/odoo-bin --config=$ODOO_RC --dev=all --database=main

# Start server (Community Edition only, port 8070)
src/community/odoo-bin --config=$ODOO_RC --dev=all \
  --addons-path=./src/community/addons \
  --http-port=8070 --gevent-port=8071 --db-filter=ce-.* --database=ce-main

# Open a debug shell
src/community/odoo-bin shell --config=$ODOO_RC --dev=all --database=main
```

The Odoo config (`$ODOO_RC` = `/etc/odoo/odoo.conf`) is auto-generated at container startup by merging the `.devcontainer/odoo/conf.d/*.conf` fragments and substituting environment variables.

## Running Tests

```sh
# Run tests by tag/module/class/method
# Prefixes: <none>=tags, /=modules, :=classes, .=methods
src/community/odoo-bin --config=$ODOO_RC --dev=all \
  --database=main --test-enable --test-tags=/module_name --stop-after-init

# Upgrade tests - prepare phase
src/community/odoo-bin --config=$ODOO_RC --dev=all --database=main \
  --upgrade-path=./src/upgrade-util/src,./src/upgrade/migrations \
  --test-enable --test-tags=upgrade.test_prepare --stop-after-init

# Upgrade tests - check phase (same but --test-tags=upgrade.test_check)
```

## Linting & Pre-commit

```sh
# Run linting manually
ruff check --fix .
ruff format .

# Install pre-commit hooks (run once after cloning)
setup-pre-commit

# Run all pre-commit hooks manually
pre-commit run --all-files
```

Pre-commit enforces: ruff (linting + formatting), yaml check, whitespace/EOF fixes, and commitizen (conventional commits) on commit-msg and pre-push.

## Repository Setup Scripts

All scripts below are on `$PATH` inside the container:

```sh
# Clone a single Odoo repository into src/<name>
setup-odoo-repository odoo community        # community edition
setup-odoo-repository enterprise            # enterprise
setup-odoo-repository upgrade
setup-odoo-repository upgrade-util
setup-odoo-repository design-themes extra-addons/design-themes
setup-odoo-repository industry extra-addons/industry

# Clone (almost) all Odoo repositories at once
setup-all-odoo-repositories

# Install pip requirements from a repo's requirements.txt
install-odoo-requirements
```

## Database Utilities

```sh
# Drop databases (supports brace expansion patterns)
odoo-db-drop -d main
odoo-db-drop -d "test{-{1..5},}"   # drops test, test-1 .. test-5

# Clone a database
odoo-db-clone -d main -t main-backup
odoo-db-clone -d main -t "test{-{1..3},}"
```

Default master password: `Password`. Override with `-mp <password>`.

## Architecture

### Source Layout

```
/work/
  src/
    community/          # Odoo CE source (git repo, cloned from github.com/odoo/odoo)
    enterprise/         # Odoo EE source (optional)
    extra-addons/       # Any extra repos cloned here; all subdirectories are
                        # auto-added to addons_path at container startup
  .devcontainer/
    Dockerfile          # Container image definition
    compose.yaml        # Docker Compose services
    odoo/
      conf.d/           # Odoo config fragments (merged into /etc/odoo/odoo.conf)
      entrypoint.d/     # Scripts run at container start (sorted by name)
        300-config-detect-addons  # Auto-discovers addons from src/
        400-config-generate       # Merges conf.d fragments + env var substitution
        500-wait-postgres         # Waits for DB readiness
      bin/              # Helper scripts placed on $PATH
  .vscode/
    launch.json         # Odoo debug launch configurations
    tasks.json          # OdooSH remote debug tunnel tasks
  odools.toml           # Odoo Language Server (odoo-ls) configuration
  .pre-commit-config.yaml
```

### Services (compose.yaml)

| Service | Port | Purpose |
|---|---|---|
| odoo | 8069-8072 | Odoo application server |
| database | - | PostgreSQL (`host=database`, `user=odoo`, `password=odoo`) |
| proxy | 80 | Nginx reverse proxy |
| mailpit | 8025 | Email capture (SMTP trap) |
| database-web-admin | 8888 | Cloudbeaver web DB client |

### Config Generation

At container startup, `entrypoint.d/300-config-detect-addons` scans `src/extra-addons/` for subdirectories and writes them into `conf.d/10-addons.conf`. Then `400-config-generate` merges all `conf.d/*.conf` fragments (sorted) into `/etc/odoo/odoo.conf`, substituting `$VAR` placeholders with environment variables. Override config via environment variables in `.devcontainer/override.env` (gitignored).

### Commit Convention

Commits must follow conventional commits format (enforced by commitizen). Example: `feat(module): add feature`, `fix: correct issue`.
