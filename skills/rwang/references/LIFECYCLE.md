# RWANG Lifecycle

## Vocabulary boundary

RWANG reserves **P0-P6** for the Genesis Block bottom-up **Block Assembly** lifecycle defined in `references/GENESIS-BLOCK-CYCLE.md`. The planning protocol uses **Design Gates DG0-DG6**, followed by **Execution**. Do not call the Design Gates phases or redefine Assembly phases here.

| Design Gate | Purpose | Canonical outputs |
|---|---|---|
| DG0 Discovery | Establish verified reality, scope, language, requirements, and roadmap. | `CODEBASE_REALITY.md`, `MASTER_PLAN.md`, scope/glossary/requirements/principles |
| DG1 Architecture | Freeze system boundaries, invariants, dependencies, and module/file structure. | architecture, decisions, invariants, dependency graph, module map |
| DG2 Contracts | Freeze interfaces, events, data, state, configuration, and errors. | contract documents |
| DG3 Agent Design | Freeze agent responsibilities, capability routing, dispatch, and review protocols. | agent architecture documents |
| DG4 Implementation Spec | Remove implementation-level architectural ambiguity. | module, pipeline, algorithm, storage, telemetry specifications |
| DG5 Quality | Define deterministic acceptance, test, security, performance, and benchmark gates. | QA documents |
| DG6 Handoff | Produce independently executable tasks and machine-readable graphs/queues. | handoff documents and queue files |
| Execution | Implement approved tasks wave by wave; verify and review each wave. | code, tests, evidence, handoff |

The Execution gate governs new planned feature/architecture work. It does not retroactively block bounded C-1 maintenance on an existing brownfield codebase; that exception is defined narrowly in `references/CORE.md` and must escalate when it changes a governed contract or boundary.

## Bootstrap and continuation

1. Inventory, in order: `state/PROJECT_STATE.json`; owner materials at root or `project/`; `docs/`; manifests/source/tests/CI; `queue/`; append-only state.
2. Determine repository kind:
   - **greenfield**: no implementation source or executable manifests; record `greenfield: true` and do not pretend a code scan occurred.
   - **brownfield**: implementation source, executable manifests, or deployed runtime exists; L1 evidence is mandatory before Master Plan work.
3. Resolve state. Missing state initializes from `templates/PROJECT_STATE.json`. `in_progress` resumes; `awaiting_approval` stops for the owner; `approved` advances; all DG0-DG6 approved enters Execution.
4. Read owner materials fully. Preserve the distinction `confirmed_code_truth`, `documented_intent`, and `unknown` in every planning artifact.
5. At a gate, write `docs/DG<N>_REVIEW.md`, update state to `awaiting_approval`, run the version audit, summarize, and stop. Only the owner may approve.

## Safe migration from 1.x state

When `state/PROJECT_STATE.json` has `current_phase` / `phase_status`, migrate once before continuing:

1. Back up the exact original as `state/migrations/PROJECT_STATE.v1.json`; never delete it.
2. Map phase `0..6` to `DG0..DG6`; map phase `7` to `Execution`.
3. Rename `phase_status` to `gate_status` without changing its value. Map `approved_phases` entries `0..6` to `approved_design_gates` `DG0..DG6`.
4. Preserve every `docs/PHASE_<N>_REVIEW.md`; do not rename history. New reviews use `DG<N>_REVIEW.md`.
5. Append a `StateMigrated` event with the source hash, target schema `2.0.0`, and exact field mapping to `state/events.jsonl`.
6. If the old state contradicts review artifacts, stop and report the conflict; do not guess an approval.

Use `scripts/migrate-state.ps1` for the deterministic field migration. It refuses to overwrite an existing backup or migrate an ambiguous/mixed schema.

## Master Plan sub-gate

`MASTER_PLAN.md` is the first DG0 planning deliverable. It must cite the current scan artifact and its SHA-256. After writing it, write `docs/MASTER_PLAN_REVIEW.md`, keep `current_design_gate = "DG0"` and `gate_status = "in_progress"`, and stop. Do not produce the rest of DG0 or `DG0_REVIEW.md` until the owner approves the Master Plan.

## Change control

Approved gates are frozen. Changes to public APIs, module boundaries, protocols, schemas, or folder structure require an owner-approved `docs/ARCHITECTURE_CHANGE_REQUEST.md`. Review and Optimize never self-approve such changes.

## Three-layer information model

- Human design truth: `docs/**/*.md`
- Machine structure: `queue/*.json`
- Runtime history: `state/*.jsonl` (append-only)

Structured values live in JSON; software does not parse Markdown for runtime dispatch. IDs are stable and never filename-derived.
