# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

_(no unreleased changes yet)_

## [1.1.0] - 2026-09-02

### Fixed

- **A failed database dump no longer produces a silent, corrupt backup.**
  The old loop piped the dump into `gzip` and only checked `gzip`'s exit
  status, so a dump that failed halfway (database down, wrong password,
  disk full) still left a small `.gz` that looked like a backup. The loop
  now runs with `pipefail`, logs `Database backup OK: <file> (<bytes>
  bytes)` or `Database backup FAILED` per cycle, keeps a failed dump as
  `<file>.failed` for diagnosis, and prunes only its own files. Retention
  set to `0` disables pruning instead of deleting everything.

### Added

- CI now waits for the first backup cycle and proves the produced
  archive is readable and contains a real dump header (plus a readable
  `tar.gz` for the data backup where the stack has one).

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

[Unreleased]: https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/heyvaldemar/xwiki-traefik-letsencrypt-docker-compose/releases/tag/v1.0.0
