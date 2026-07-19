# Governed-Artifact Versioning

Git owns source history. Package/application SemVer owns releases. RWANG's `.rwang/` sidecar owns approval and drift history only for explicitly governed artifacts such as specs, ADRs, schemas, policies, contracts, and approved deliverables.

Source code is not registered per file by default. Link implementation to an approved task/spec and Git commit instead. Never implicitly govern `src/**`.

## Registry contract

`.rwang/registry.json` must declare scope before registration:

```json
{
  "registry_version": "2.0.0",
  "governed_scope": {
    "include": ["docs/specs/**", "docs/adr/**", "schemas/**", "policies/**", "docs/MASTER_PLAN.md"],
    "exclude": ["docs/archive/**", "docs/generated/**"]
  },
  "items": []
}
```

Report scope on init/status/audit. Never imply coverage beyond `include - exclude`. Registration outside scope must fail until the owner explicitly changes the declaration.

## Actions

- `audit` (default): read-only; report orphan sidecars, unregistered governed files, hash drift, index drift, invalid metadata, and out-of-scope registrations.
- `register <path>`: register only in-scope artifacts at `0.1.0` draft with a real SHA-256.
- `bump <path> major|minor|patch <reason>`: update hash, SemVer, and append changelog. A frozen major bump requires a cited approved change request.
- `fix`: repair deterministic index/sidecar disagreement only. Never invent an intent or bump for changed content; report the required owner decision.

Prefer `scripts/version-governance.ps1` so hashing, scope matching, ID allocation, and drift checks are deterministic.

For this sidecar, `beta` and `stable` statuses are frozen. A standard SemVer prerelease suffix (for example `1.2.0-beta`) is valid; the next major/minor/patch bump increments the numeric core and removes the prerelease suffix.

## Write gate

The pre-commit hook checks only registered governed artifacts. It handles staged paths with spaces/NUL-safe enumeration. A changed registered artifact and its matching sidecar must be staged together, and the sidecar's current `sha256` field must match staged content. Direct deletion is rejected until an explicit deprecate/supersede workflow exists. Never overwrite an existing hook; request a manual merge. Never bypass with `--no-verify`.

Run audit at bootstrap, before each owner approval request, and before merge. In RWANG projects, append summary events to `state/events.jsonl` for mutating actions; status/audit remain read-only unless the owner explicitly requests recording.
