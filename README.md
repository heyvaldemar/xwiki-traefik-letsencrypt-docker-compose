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

The weekly `check-pin-freshness` CI job re-resolves each pin against its registry and compares the pinned XWiki and Traefik versions against the latest upstream releases. GitHub Actions are pinned by commit SHA; Dependabot keeps those fresh.

## Production checklist

- [ ] **Strong database password** — 24+ random characters; regenerate the Traefik dashboard hash.
- [ ] **Create the admin account promptly** — complete XWiki's setup on first visit.
- [ ] **Host-mount the backup volumes** for disaster recovery.
- [ ] **Back up before upgrades** — XWiki migrates its schema on version jumps; restore is the rollback.
- [ ] **Size the host generously** — XWiki wants 2 GB+ heap; add `JAVA_OPTS` if you need to tune it.

## Backups and restore

The `backups` container runs a `pg_dump | gzip` + `tar.gz`-of-data → prune → sleep loop (defaults: 30-minute warm-up, 24-hour interval, 7-day retention). Restore with the interactive scripts (`chmod +x *.sh` once): `./xwiki-restore-database.sh`, then `./xwiki-restore-application-data.sh`.

## Testing

The [Deployment Verification](https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/actions/workflows/deployment-verification.yml?query=branch%3Amain) workflow runs on every push, pull request, and every Monday at 06:00 UTC: shellcheck + actionlint, Trivy scans of all three pinned images, the weekly freshness check, and a deploy-and-test job that boots the stack with ephemeral credentials, waits out first-start initialization, and requires the wiki UI to answer through Traefik.

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
