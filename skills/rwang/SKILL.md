---
name: rwang
description: RWANG umbrella workflow for init, scan, plan, continue, status, and governed-artifact version control. Also routes the legacy commands RWANG:QuickStart, RWANG:MasterPlan, RWANG:Core, and RWANG:Version. Use for RWANG project onboarding, codebase reality scans, design-gate planning, project continuation, state reporting, and version audits.
version: 2.1.1-beta
---

# RWANG

RWANG has one primary entry point. Load `references/CORE.md` for every command, then route the request below. Do not copy RWANG module files into the project; project artifacts stay project-specific.

| Command | Route |
|---|---|
| `RWANG:init` | Inventory, initialize scoped governance, run the required scan, write the Master Plan, then stop at its owner-review gate. |
| `RWANG:scan [--deep]` | Follow `references/CODEBASE-SCAN.md`. Default to L1 for brownfield; `--deep` selects L2. |
| `RWANG:plan` | Follow `references/LIFECYCLE.md`; require current scan evidence before writing or revising a brownfield Master Plan. |
| `RWANG:continue` | Resolve `state/PROJECT_STATE.json`, then continue the current Design Gate or Execution wave. |
| `RWANG:status` | Report scan evidence, current Design Gate, approvals, governed scope, drift, blockers, and next action. Read-only. |
| `RWANG:version [audit|register|bump|fix]` | Follow `references/VERSION-GOVERNANCE.md`; prefer the deterministic script. |

Legacy aliases remain callable during migration and must emit one concise deprecation note:

- `RWANG:QuickStart` -> `RWANG:init`
- `RWANG:MasterPlan` -> `RWANG:plan` for a fresh plan, otherwise `RWANG:continue`
- `RWANG:Core` -> reload `references/CORE.md`
- `RWANG:Version` -> `RWANG:version audit` unless an action follows

The full compatibility policy is in `references/LEGACY-ALIASES.md`. Explicit retired skill selectors such as `$rwang-quickstart` cannot resolve after the old skill folders are removed; this intentional 2.0 breaking change must be reported honestly with the canonical replacement `$rwang` plus command text.

## Required execution order for init and plan

1. Read `references/CORE.md` and classify complexity/risk.
2. Read `references/GENESIS-BLOCK-CYCLE.md`; it is the SSOT for Block Assembly P0-P6 and Block Decomposition Stage 1-12.
3. Read `references/LIFECYCLE.md` and inventory owner materials, state, docs, manifests, source, tests, and automation.
4. Read `references/CODEBASE-SCAN.md` and establish L0/L1/L2 evidence.
5. If brownfield, refuse to write the Master Plan until L1 or L2 evidence exists and is cited by hash. If greenfield, record that no source exists.
6. Read `references/VERSION-GOVERNANCE.md`; initialize only explicit governed-artifact scopes.
7. Write/revise the Master Plan from owner intent plus verified code truth, label unknowns, write `docs/MASTER_PLAN_REVIEW.md`, and stop for owner approval.

Never treat documented intent as code truth. Never claim a deep 12-stage decomposition unless every L2 stage has evidence or is explicitly marked incomplete.

## Changelog

| Version | Date | Status | Change |
|---|---|---|---|
| 2.1.1-beta | 2026-07-19 | beta | Hardened C-1 brownfield scope, legacy Stage 1 provenance, scan/Git evidence, installers, pre-commit path handling, and regression coverage. |
| 2.1.0-beta | 2026-07-19 | beta | Added the combined Genesis Block Cycle SSOT for 7-phase Assembly and 12-stage Decomposition; subordinate references no longer redefine the canonical lists. |
| 2.0.0-beta | 2026-07-19 | beta | Consolidated Core, QuickStart, MasterPlan, and Version command surfaces; added mandatory brownfield reality evidence, Design Gate vocabulary, scoped governance, and legacy routing. |
