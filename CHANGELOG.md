# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

_(no unreleased changes yet)_

## [1.0.0] - 2026-09-01

First semver release. Brings this template to the fleet standard established
in [keycloak-traefik-letsencrypt-docker-compose](https://github.com/heyvaldemar/keycloak-traefik-letsencrypt-docker-compose)
v1.2.0.

### Changed (BREAKING for existing deployments)

- **XWiki 15.7 (EOL since 2023) → 18.7.0.** ❗ XWiki upgrades across this
  many majors need care: back up first, and expect the automated
  distribution upgrade to run migrations on first start — see the release
  notes for the path. Traefik 3.2 → 3.7 (3.2's Docker client cannot talk
  to Docker Engine 29); PostgreSQL 15 digest-pinned.
- **All images pinned by `tag@sha256:digest`** in the compose `x-images`
  block; `.env` carries only secrets and deliberate overrides.

### Security

- **Credentials untracked from git.** The tracked `.env` carried a
  generated-looking database password — rotate it if reused.

### Fixed

- Backup-loop variables are `$$`-escaped so the container shell resolves
  them at runtime; shellcheck findings in both restore scripts.

### Added

- **Deployment Verification workflow**: shellcheck + actionlint; Trivy
  scans of all three pinned images; weekly `check-pin-freshness` (digest
  drift + XWiki tag lag + Traefik release lag); and a deploy-and-test job
  that boots the stack, waits out XWiki's first-start initialization, and
  requires the wiki UI to answer through Traefik.

[Unreleased]: https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/releases/tag/v1.0.0
