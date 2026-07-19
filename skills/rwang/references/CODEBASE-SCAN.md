# Codebase Reality Scan

The scan is a planning evidence gate, not a claim that every file was understood. Ignore dependencies, generated/build output, caches, binaries, VCS internals, and secrets. Record scope and omissions.

## Profiles

### L0 - Inventory

Required for every project: repository root, Git HEAD/status, owner materials, existing RWANG state, top-level structure, manifests, and whether the repository is greenfield or brownfield.

### L1 - Reality Scan

Mandatory before planning a brownfield project. Inspect and cite:

- source roots and representative implementations
- package/workspace manifests and dependency boundaries
- runtime/build entry points
- existing build, test, lint, typecheck, and smoke commands
- public routes/APIs/tools, schemas, persistence, and external integrations
- CI/CD and deployment configuration
- docs-versus-code drift
- unknowns, excluded paths, and confidence limits

Write `docs/discovery/CODEBASE_REALITY.md` and `.rwang/evidence/codebase-snapshot.json`. The Markdown artifact must cite the snapshot SHA-256. A Master Plan must cite both.

### L2 - 12-stage Block Decomposition

Use only for C-3 work, large/legacy/ambiguous systems, architecture recovery, or explicit `RWANG:scan --deep`. L2 includes L0/L1 and executes the canonical Stage 1–12 defined exclusively in `references/GENESIS-BLOCK-CYCLE.md`.

Do not restate, rename, or reorder those stages here. Each stage records inputs, method, output, exclusions, confidence, and status using the SSOT completion rules. A grep-only inventory is not a completed Symbol Graph.

## Deterministic helper

Run `scripts/scan-codebase.ps1 -Root <repo> -Profile L0|L1|L2`. It creates the bounded machine snapshot and a Markdown evidence skeleton. For L2, it prepares the evidence packet; the agent must complete and validate all 12 stages before claiming L2 completion.

For a brownfield repository, helper output is never sufficient by itself: `planning_gate_satisfied` remains `false` until the agent inspects representative implementations, records confirmed code truth and documentation drift, resolves or exposes unknowns, and updates the evidence status. Do not treat file inventory as completed L1 validation.

## Planning gate

- Brownfield + missing/stale L1/L2 evidence -> stop planning and scan.
- Greenfield -> record `greenfield: true`, scan profile L0, and the absence of source.
- A snapshot is stale when its recorded Git HEAD differs from current HEAD or material source/manifests changed. Refresh before revising architecture claims.
