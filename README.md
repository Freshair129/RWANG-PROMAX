# RWANG PROMAX

RWANG is an agent-agnostic, evidence-first project workflow distributed as three skills.

Architecture authority: [`docs/ARCHITECTURE--RWANG-SKILL-CONSOLIDATION.md`](./docs/ARCHITECTURE--RWANG-SKILL-CONSOLIDATION.md). This document owns the public skill topology, command/module boundaries, installation model, migration contracts, and acceptance evidence for RWANG 2.x.

| Skill | Responsibility |
|---|---|
| `rwang` | `init`, `scan`, `plan`, `continue`, `status`, and governed-artifact `version` operations |
| `rwang-review` | read-only engineering review |
| `rwang-optimize` | measured, architecture-preserving implementation optimization |

Version 2.0 consolidates the former Core, QuickStart, MasterPlan, and Version skill surfaces into `rwang`. The policy remains modular under `skills/rwang/references/`; deterministic operations live under `skills/rwang/scripts/`.

## Genesis Block Cycle SSOT

[`skills/rwang/references/GENESIS-BLOCK-CYCLE.md`](./skills/rwang/references/GENESIS-BLOCK-CYCLE.md) is the installed operational SSOT for:

- Block Assembly — seven bottom-up phases `P0..P6`
- Block Decomposition — twelve top-down stages `1..12`
- handoff, evidence, completion, feedback, and change-control contracts between both halves

`CODEBASE-SCAN.md` and `LIFECYCLE.md` consume this SSOT and must not redefine the canonical phase or stage lists.

## Install

```powershell
iwr -useb https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.ps1 | iex
```

```sh
curl -fsSL https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.sh | sh
```

The installer places exactly three skills in `~/.agents/skills` and links supported harness directories to that SSOT. Start in a project with:

```text
RWANG:init
```

Codex users can select `$rwang`; Claude users can select `/rwang`.

For a workspace-local installation used by agents without a machine skill registry:

```powershell
.\rwang-init.ps1 C:\path\to\project
```

```sh
./rwang-init.sh /path/to/project
```

Workspace init requires the machine install, links `.agents/skills/` to the global SSOT, and adds small `AGENTS.md` / `CLAUDE.md` dispatch files. It never copies skill or command-module payloads into the project.

## Reality before planning

`RWANG:init` and `RWANG:plan` classify the repository first:

- Greenfield uses L0 inventory and records that no source exists.
- Brownfield requires L1 Codebase Reality evidence before a Master Plan can be written.
- L2 runs only for C-3, large/legacy/ambiguous systems, architecture recovery, or explicit `RWANG:scan --deep`.

L2 uses the canonical Genesis Block 12-stage top-down Block Decomposition vocabulary: Scan, Structure, specialized Markdown/COBOL parsing, Symbolic Parse, Routes, Tools, ORM, Cross-File Resolution, MRO, Communities, and Processes. The helper prepares evidence; it never labels an incomplete graph as complete.

## Lifecycle vocabulary

P0-P6 is reserved for the bottom-up Genesis Block Assembly lifecycle. RWANG planning uses Design Gates DG0-DG6 plus Execution, avoiding a second incompatible meaning of “7 phases.”

Existing 1.x state migrates deterministically from `current_phase` to `current_design_gate`, with the original backed up and all `PHASE_<N>_REVIEW.md` history preserved.

## Version governance

Git owns source history; package SemVer owns releases. `.rwang` tracks only explicitly scoped governed artifacts such as specifications, ADRs, schemas, policies, contracts, and approved deliverables. It never registers `src/**` implicitly.

## Legacy commands

Plain-text commands remain routable during migration:

- `RWANG:QuickStart` -> `RWANG:init`
- `RWANG:MasterPlan` -> `RWANG:plan` or `RWANG:continue`
- `RWANG:Core` -> automatic Core policy reload
- `RWANG:Version` -> `RWANG:version`

Explicit retired selectors (`$rwang-quickstart`, `$rwang-masterplan`, `$rwang-core`, `$rwang-version`) are breaking removals in 2.0 because harnesses resolve them by installed folder name. Use `$rwang` plus the canonical command.

## Validate the bundle

```powershell
./scripts/validate-bundle.ps1
./scripts/test-functional.ps1
./scripts/test-installers.ps1
```

```sh
sh ./scripts/test-installers.sh
```

The bundle validator fails on missing references, duplicate bundled Markdown payloads, public skill-count regression, non-canonical L2 vocabulary, implicit source governance, or installer allowlist drift. Functional tests exercise scan gating, state migration, version drift, recoverable installation, and project-to-global SSOT links in isolated temporary directories.

## Version diff

- `rwang`: `2.1.1-beta` (umbrella plus hardened brownfield/runtime/installer governance)
- `rwang-review`: `1.0.x` -> `1.1.0` (bundled SSOT repaired; Design Gate vocabulary)
- `rwang-optimize`: `1.0.x` -> `1.1.0` (bundled SSOT repaired; Design Gate vocabulary)

No automatic installation, commit, push, release, or tag occurs when editing this source repository.

## License

[MIT](./LICENSE)
