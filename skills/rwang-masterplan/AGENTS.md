# RWANG — Agent Working Agreement

This project uses the **RWANG:** protocol family. It is tool-neutral — these instructions apply to any agent that reads this file (Codex, Cursor, Cline, Aider, local LLMs, etc.).

## Always in effect

If `RWANG-CORE.md` exists at the project root, its rules **R1–R6 apply to every task at all times** — read it before doing anything else.

## On session start

Read `RWANG-MASTERPLAN.md` and execute its **Bootstrap Protocol** immediately (inventory the repo, resolve the current phase from `state/PROJECT_STATE.json`, and continue or start work). No other prompt is required.

## Command dispatch

When the user invokes a RWANG command, open the matching file at the project root and follow it exactly:

| User says | Read this file | What it does |
|---|---|---|
| `RWANG:MasterPlan` | `RWANG-MASTERPLAN.md` | Bootstrap / continue the architecture-first project |
| `RWANG:Core` | `RWANG-CORE.md` | (Re)load the standing rules R1–R6 — always in effect once present |
| `RWANG:Review` | `RWANG-REVIEW.md` | Engineering review of a diff / task / wave / phase — report only |
| `RWANG:Optimize` | `RWANG-OPTIMIZE.md` | Measured, architecture-preserving optimization |
| `RWANG:Version` | `RWANG-VERSION.md` | Sidecar SemVer registry: register, bump, audit + commit write gate |

The command may include a target or action after it (e.g. `RWANG:Review src/parser.ts`, `RWANG:Version bump docs/10_DATA_MODELS.md minor "add event schema"`) — pass it to the module.

## Non-negotiable rules (from RWANG-MASTERPLAN.md)

- The human owner is the **only** approval authority. Approved phases are frozen.
- During design phases (0–6) agents do **not** write production code.
- No agent renames public APIs, merges modules, changes protocols, or alters folder structure without an approved `ARCHITECTURE_CHANGE_REQUEST.md`.
- `README.md` is reserved for humans — never overwrite it.
- Never modify files registered in `.rwang/` without going through `RWANG:Version bump`; never bypass the pre-commit gate with `--no-verify`.

If a RWANG module file referenced above is not present in this project, fetch it from https://github.com/Freshair129/RWANG-PROMAX or tell the owner it is missing.
