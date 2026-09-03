# XWiki + Traefik + Let's Encrypt — Docker Compose

[![Deployment Verification](https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/actions/workflows/deployment-verification.yml/badge.svg?branch=main)](https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/actions/workflows/deployment-verification.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository deploys **XWiki** — an enterprise wiki platform — behind **Traefik** with automatic **Let's Encrypt TLS**, backed by **PostgreSQL 15**, with scheduled **backups** (database + wiki data) and companion **restore scripts**.

📙 Full narrative installation guide on the blog: [heyvaldemar.com/install-xwiki-with-docker-compose/](https://www.heyvaldemar.com/install-xwiki-with-docker-compose/).

## Getting started

```bash
# 1. Clone
git clone https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose
cd xwiki-traefik-letsencrypt-docker-compose

# 2. Create the two Docker networks the stack expects
docker network create traefik-network
docker network create xwiki-network

# 3. Copy the environment template and fill in required values
cp .env.example .env
$EDITOR .env
# ^ Required: XWIKI_DB_PASSWORD, XWIKI_HOSTNAME,
#   TRAEFIK_HOSTNAME, TRAEFIK_ACME_EMAIL, TRAEFIK_BASIC_AUTH.

# 4. Deploy
docker compose -f xwiki-traefik-letsencrypt-docker-compose.yml -p xwiki up -d
```

First start takes several minutes: XWiki initializes its schema and core pages before the UI answers. Watch progress with `docker logs -f xwiki-xwiki-1`.

### What success looks like

```bash
docker compose -f xwiki-traefik-letsencrypt-docker-compose.yml -p xwiki ps
curl -fskL -o /dev/null -w "%{http_code}\n" "https://${XWIKI_HOSTNAME}/"
```

### Common first-deploy issues

- **Cert issuance fails.** DNS hasn't propagated or port 80 isn't reachable from the internet.
- **Timeouts in the first minutes.** Normal — XWiki's first-start initialization is heavy. Give it five minutes before debugging.
- **`docker compose up` fails with `set in .env`.** A required variable is empty; the error names it.
- **Networks not found.** Step 2 was skipped.

## Supply chain trust

Three images — [`traefik`](https://hub.docker.com/_/traefik), [`xwiki`](https://hub.docker.com/_/xwiki), [`postgres`](https://hub.docker.com/_/postgres), all Docker Hub official — pinned to `tag@sha256:<digest>` as interpolation defaults in the compose `x-images` block. `git pull` alone delivers the tested combination; an `*_IMAGE_TAG` variable in `.env` overrides deliberately.

The daily `check-pin-freshness` CI job re-resolves each pin against its registry and compares the pinned XWiki and Traefik versions against the latest upstream releases. GitHub Actions are pinned by commit SHA; Dependabot keeps those fresh.

## Production checklist

- [ ] **Strong database password** — 24+ random characters; regenerate the Traefik dashboard hash.
- [ ] **Create the admin account promptly** — complete XWiki's setup on first visit.
- [ ] **Host-mount the backup volumes** for disaster recovery.
- [ ] **Back up before upgrades** — XWiki migrates its schema on version jumps; restore is the rollback.
- [ ] **Size the host generously** — XWiki wants 2 GB+ heap; add `JAVA_OPTS` if you need to tune it.

## Backups and restore

The `backups` container runs a `pg_dump | gzip` + `tar.gz`-of-data → prune → sleep loop (defaults: 30-minute warm-up, 24-hour interval, 7-day retention). Restore with the interactive scripts (`chmod +x *.sh` once): `./xwiki-restore-database.sh`, then `./xwiki-restore-application-data.sh`.

## Resource limits

Every service carries memory and CPU limits plus reservations as compose-level defaults — the same values CI boots the stack under. Override any of them in `.env` (the knobs and their defaults are listed in `.env.example`, e.g. `TRAEFIK_MEMORY_LIMIT=512m`) and the override survives every `git pull`. If a service is OOM-killed under real load, `docker inspect <container> --format '{{.State.OOMKilled}}'` says so; raise its `_MEMORY_LIMIT` and recreate.

## Testing

The [Deployment Verification](https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/actions/workflows/deployment-verification.yml?query=branch%3Amain) workflow runs on every push, pull request, and every day at 06:00 UTC: shellcheck + actionlint, Trivy scans of all three pinned images, the weekly freshness check, and a deploy-and-test job that boots the stack with ephemeral credentials, waits out first-start initialization, and requires the wiki UI to answer through Traefik.

### Backup and restore, proven

`tests/e2e-backup-restore.sh` runs against the live stack and is what CI executes after the HTTPS smoke. The scenario that matters most is the restore roundtrip: insert a marker row, restore the earliest backup, assert the marker is gone — a backup that cannot be restored fails the build. Run it yourself against a running deployment with short intervals in `.env` (`BACKUP_INIT_SLEEP=15s`, `BACKUP_INTERVAL=60s`):

```bash
chmod +x tests/e2e-backup-restore.sh
./tests/e2e-backup-restore.sh
```

It stops the database container briefly to prove failure detection — run it on a staging copy, not on production.

## Security Notes

- Credentials are read from `.env` at deploy time; `.env` is gitignored and compose fails fast on missing required variables.
- **Pre-rotation advisory.** Releases before v1.0.0 (2026-09-01) shipped a tracked `.env` with a generated-looking database password. Rotate it if your deployment reused it.
- PostgreSQL listens only on the internal network.

---

## About the maintainer

<div align="center">

**Maintained by [Vladimir Mikhalev](https://github.com/heyvaldemar)** — Docker Captain · IBM Champion · AWS Community Builder

[YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1) · [Blog](https://heyvaldemar.com) · [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)

</div>
