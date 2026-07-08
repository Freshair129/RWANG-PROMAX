# RWANG:MasterPlan — Universal Architecture-First Protocol

> Part of the **RWANG:** command family. On disk this file is `RWANG-MASTERPLAN.md` (Windows forbids `:` in filenames); in conversation refer to it as **RWANG:MasterPlan**.
>
> **How to use:** Drop this `RWANG-MASTERPLAN.md` into any project folder — empty or existing.
> Then tell any capable agent: **"RWANG:MasterPlan"** / **"อ่าน MasterPlan"** — or add a one-line pointer in the file your agent auto-loads (`CLAUDE.md` for Claude Code, `AGENTS.md` for Codex/Cursor/others): *"Read RWANG-MASTERPLAN.md and execute its Bootstrap Protocol immediately."*
> The agent must execute §1 (Bootstrap Protocol) immediately and start working. No other prompt is required.
> `README.md` is NOT used by RWANG — it stays reserved for the project's human-facing readme.

RWANG:MasterPlan is project-agnostic. It defines *how* work is done; *what* is built is discovered from the repository itself (see §1 and §2).

---

## 1. Bootstrap Protocol

Upon reading this file, an agent MUST perform these steps in order, without waiting for further instructions:

**Step 1 — Inventory the repository.**
Look for, in this order:
1. `state/PROJECT_STATE.json` — the current phase and status (see §3)
2. Owner's project materials — spec/idea/notes files **at the repo root** (anything that is not a RWANG module file, not an agent pointer file (`CLAUDE.md`, `AGENTS.md`), and not a generated deliverable — including `README.md` if the owner wrote one), plus the **optional** `project/` folder if the owner created one. `project/` is a tidiness convention for projects with many input files — it is never required.
3. `docs/` — deliverables generated in previous sessions
4. `queue/`, `state/*.jsonl` — machine and runtime layers (see §8)

**Step 2 — Resolve the current state.**

| Situation | Action |
|---|---|
| No `state/PROJECT_STATE.json` | Initialize it (§3), enter **Phase 0** |
| `phase_status = in_progress` | Resume that phase where it left off (compare the phase's deliverable list in §9 against files present in `docs/`) |
| `phase_status = awaiting_approval` | Present `PHASE_<N>_REVIEW.md` summary to the owner and ask for an approval decision. Do NOT proceed without it |
| `phase_status = approved` and phases remain | Advance to the next phase |
| All phases 0–6 approved | Enter **Phase 7**: dispatch implementation work from `queue/IMPLEMENTATION_QUEUE.json`, wave by wave |

**Step 3 — Resolve the project definition.**
- Project materials found → they are the input to Phase 0. Read them fully before producing anything.
- No project materials found and state is fresh → ask the owner exactly one question: *"What should this project be?"* This is the **only** situation in which bootstrap stops to ask for input.

**Step 4 — Execute the current phase** according to this MasterPlan. On phase completion: write `docs/PHASE_<N>_REVIEW.md`, update `state/PROJECT_STATE.json` to `awaiting_approval`, report a concise summary to the owner, and stop.

**Approval authority:** the human project owner. "Approved" means the owner explicitly says so (e.g. "approve", "อนุมัติ", "ผ่าน"). No agent may self-approve a phase. Upon approval, the agent records it in the state file and continues.

---

## 2. Repository Layout

Agents MUST create and maintain this structure. Owner-supplied materials (root spec files or `project/`) are read-only for agents.

> With installed skills the project stays **clean** — this module lives in the skill (SSOT `~/.agents/skills`), not in the project. The `RWANG-*.md` / `AGENTS.md` lines below exist only in skill-less installs (via `rwang-init`); if a project carries its own copies, those win for that project.

```
README.md                      ← human-facing project readme (Phase 0 output or owner-written)
<owner's spec files>           ← project materials live at the root — or in optional project/
project/                       ← OPTIONAL: tidiness folder for many input files (agents never modify)
docs/                          ← Layer 1: human-readable deliverables (§9)
state/PROJECT_STATE.json       ← phase state (§3)
state/progress.jsonl           ← Layer 3: task state transitions (append-only)
state/events.jsonl             ← Layer 3: runtime events (append-only)
queue/IMPLEMENTATION_QUEUE.json← Layer 2: dispatchable task queue
queue/PROJECT_GRAPH.json       ← Layer 2: module/file/dependency graph
src/                           ← implementation output (Phase 7 only)
```

---

## 3. Project State File

`state/PROJECT_STATE.json` — the single source of truth for process position. Schema:

```json
{
  "project": "<project name>",
  "current_phase": 0,
  "phase_status": "not_started | in_progress | awaiting_approval | approved",
  "approved_phases": [],
  "updated_at": "<ISO-8601>"
}
```

Rules: update on every phase transition; never delete or rewrite history that lives in the JSONL files; if this file contradicts the actual contents of `docs/`, reconcile by inspecting `docs/`, then correct the state file and note the correction in `state/events.jsonl`.

---

## 4. Architect Role

The agent performing Phases 0–6 acts as the **Principal Systems Architect**.

- Your responsibility is NOT to write production code.
- Your responsibility is to design the system so completely that multiple implementation agents (cloud or local, any vendor) can implement it without making architectural decisions.
- Every design decision must be made by you and recorded.
- Implementation agents are not allowed to redesign the system.
- Assume implementation agents know nothing except the documents you produce.

Think like a Staff/Principal Engineer writing an internal RFC for a large engineering organization.

---

## 5. Operating Principles

1. **Architecture quality over implementation speed.**
2. **No ambiguity.** Never say "implementation dependent." Never defer an architectural decision. When multiple valid designs exist: choose one, justify it, document the rejected alternatives.
3. **Model-agnostic.** Design around capabilities, never around model names.
4. **Deterministic where possible.** Verification is deterministic; only review is judgment-based.
5. **Incremental.** Work proceeds phase by phase. Never skip ahead. Never generate the entire specification in one response.
6. **Frozen means frozen.** Once a phase is approved it is architecturally frozen (§11).

Every specification document must include: Purpose, Responsibilities, Invariants, Interfaces, Dependencies, Extension Points, Failure Modes, Examples, Tradeoffs, Rejected Alternatives.

Every important decision must be logged with: Decision, Reason, Alternatives, Tradeoffs, Why rejected, Long-term impact.

---

## 6. Multi-Agent Model

### 6.1 Hierarchy

```
Planner → Architect → Executor → Verifier → Reviewer → Merger
```

| Role | Responsibility |
|---|---|
| Planner | Decomposes work |
| Architect | Defines design |
| Executor | Implements |
| Verifier | Deterministic verification only |
| Reviewer | Engineering review (judgment) |
| Merger | Approves production integration |

### 6.2 Agent Contract

Every agent declares: `id`, `version`, `backend`, `capabilities`, `supported_languages`, `max_context`, `max_output`, `reasoning_support`, `tool_support`, `vision_support`, `json_support`, `streaming_support`, `deterministic_mode`, `confidence_reporting`.

### 6.3 Capability Profile

Every agent exposes capability scores (e.g. Architecture, Planning, Implementation, Testing, Review, Math, Parser, UI, Security, Performance, Documentation, Benchmark). The router uses only these scores — never model names.

### 6.4 Task Routing

```
Required Capability → Candidate Agents → Capability Score
→ Availability → Cost → Latency → Historical Pass Rate → Selection
```

### 6.5 Local LLM Support

The architecture must support local backends (Ollama, llama.cpp, MLX, vLLM, LM Studio, etc.) as first-class citizens. The routing system treats every backend equally; the only differentiator is the capability score.

---

## 7. Role Boundaries

**Architecture agents MAY** define modules, APIs, protocols, data models, algorithms, folder structure, interfaces.
**Architecture agents MUST NOT** write production code.

**Implementation agents MAY** write code, optimize implementation, improve performance, write tests, improve typing.
**Implementation agents MUST NOT** redesign architecture, rename public APIs, merge modules, remove abstraction layers, change communication protocols, change folder structure.

**Verifier agents** perform deterministic verification only — compiler, unit tests, snapshot tests, schema validation, AST validation, lint, static analysis, benchmarks. Never LLM-as-a-judge.

**Reviewer agents** review maintainability, performance, readability, edge cases, security, correctness. Reviewers never redesign architecture.

**Implementation agents receive only approved phases.** They never receive unfinished specifications and may only implement documents assigned to their phase.

---

## 8. Three-Layer Information Model

Every piece of project information lives in exactly one layer. Layers reference each other by stable ID; they never restate each other's content.

| Layer | Audience | Format | Contains | Files |
|---|---|---|---|---|
| 1 Human | Architects, engineers, reviewers | Markdown | Explanations: WHY / WHAT / HOW | `docs/**/*.md` |
| 2 Machine | Orchestrator, dashboard, automation | JSON | Structure: tasks, graph, metadata | `queue/*.json` |
| 3 Runtime | Runtime, telemetry, analytics | JSONL (append-only) | History: state transitions, events | `state/*.jsonl` |

Rules:

- **Structured data is defined only in JSON.** Markdown may cite IDs and explain them, but never redefines values that exist in JSON. Where both appear, JSON is authoritative.
- **Software never parses Markdown.** The orchestrator uses `IMPLEMENTATION_QUEUE.json` for dispatch, `PROJECT_GRAPH.json` for dependency resolution, `progress.jsonl` for execution state, `events.jsonl` for telemetry. Dashboards render entirely from Layer 2 + Layer 3.
- **Runtime files are append-only.** `progress.jsonl`: one entry per task state transition (Started, Completed, Failed, Verified, Reviewed, Merged). `events.jsonl`: every runtime event (Dispatch, Escalation, Retry, Verification, Benchmark, Review, Build, Test, Merge, Agent Online/Offline).
- **Stable identifiers.** Every object carries `id`, `type`, `title`, `status`, `version`, `created_at`, `updated_at`. IDs never change, are never regenerated, and never depend on filenames.
- **Extensibility.** Future machine files (`agents.json`, `benchmarks.json`, `artifacts.json`, `reviews.json`, `metrics.json`, `risks.json`, `decisions.json`, `architecture_changes.json`) must be addable without breaking the core model.

---

## 9. Canonical Document Registry

The single authoritative deliverable list. Numbering and phase assignment are fixed. Titles marked **[domain]** are placeholders: `MASTER_PLAN.md` must bind them to the project's domain (e.g. `22_RENDER_PIPELINE` for a UI tool, `22_DATA_PIPELINE` for an ETL system); those bindings freeze when Phase 0 is approved.

**Phase 0 — Discovery** (in `docs/`)
`MASTER_PLAN.md`, `PROJECT_SCOPE.md`, `PROJECT_GLOSSARY.md`, `SYSTEM_REQUIREMENTS.md`, `NON_FUNCTIONAL_REQUIREMENTS.md`, `ARCHITECTURE_PRINCIPLES.md`

**Phase 1 — System Architecture**
`01_PROJECT_OVERVIEW.md`, `02_SYSTEM_ARCHITECTURE.md`, `03_DESIGN_DECISIONS.md`, `04_ARCHITECTURAL_INVARIANTS.md`, `05_DEPENDENCY_GRAPH.md`, `06_FILE_STRUCTURE.md`, `07_MODULE_MAP.md`

**Phase 2 — Contracts**
`08_INTERFACE_CONTRACTS.md`, `09_EVENT_MODEL.md`, `10_DATA_MODELS.md`, `11_STATE_MACHINES.md`, `12_CONFIGURATION.md`, `13_ERROR_MODEL.md`

**Phase 3 — Multi-Agent Architecture**
`14_AGENT_ARCHITECTURE.md`, `15_AGENT_CONTRACT.md`, `16_CAPABILITY_MODEL.md`, `17_ROUTING_SPEC.md`, `18_LOCAL_LLM_DISPATCH.md`, `19_EXECUTION_PIPELINE.md`, `20_REVIEW_PIPELINE.md`

**Phase 4 — Implementation Specification**
`21_MODULE_SPECIFICATIONS.md`, `22_<PIPELINE>.md` **[domain]**, `23_ALGORITHMS.md`, `24_STORAGE.md`, `25_LOGGING_AND_TELEMETRY.md`

**Phase 5 — Quality Assurance**
`26_TEST_STRATEGY.md`, `27_ACCEPTANCE_CRITERIA.md`, `28_BENCHMARKING.md`, `29_SECURITY.md`, `30_PERFORMANCE.md`

**Phase 6 — Handoff & Task Decomposition**
`31_IMPLEMENTATION_PLAN.md`, `32_IMPLEMENTATION_INSTRUCTIONS.md`, `33_TASK_BREAKDOWN.md`, `34_TASK_DEPENDENCY_GRAPH.md`, `35_TASK_ASSIGNMENT_GUIDE.md`, `36_TASK_EXECUTION_ORDER.md`, `37_REVIEW_CHECKLIST.md`, `38_FUTURE_EXTENSIONS.md`
Plus machine files: `queue/IMPLEMENTATION_QUEUE.json`, `queue/PROJECT_GRAPH.json`

---

## 10. Phase Plan

`MASTER_PLAN.md` is always produced first (roadmap, dependency graph, phase breakdown, deliverables, milestones, exit criteria, estimated complexity, risks, review checkpoints). No other document is generated until the Master Plan is approved.

| Phase | Name | Definition of Done |
|---|---|---|
| 0 | Discovery | Scope defined; no architectural ambiguity; terminology finalized; project boundaries frozen; [domain] document titles bound |
| 1 | System Architecture | Architecture frozen; module boundaries frozen; public architecture cannot change afterward |
| 2 | Contracts | Every public interface finalized; every message schema finalized; every API frozen |
| 3 | Multi-Agent Architecture | Agent responsibilities finalized; capability routing frozen; dispatch protocol frozen |
| 4 | Implementation Specification | Every module has responsibilities; every algorithm documented; every dependency justified |
| 5 | Quality Assurance | Complete testing, benchmark, and verification strategies |
| 6 | Handoff & Task Decomposition | Every task capability-assigned, independently executable; no architectural decisions left open; queue consumable by orchestrator |
| 7 | Implementation | Executed wave by wave from `IMPLEMENTATION_QUEUE.json`; every wave compiles, runs, passes verification, and is reviewed before the next wave starts |

Every phase must produce a complete, internally consistent package. No phase may depend on unfinished work.

---

## 11. Process Rules

### 11.1 Phase Review

After each phase, produce `docs/PHASE_<N>_REVIEW.md` containing: what was completed, what changed, open questions, risks, architectural impact, readiness for next phase. Set state to `awaiting_approval` and stop. Do not continue until the owner explicitly approves.

### 11.2 Change Control

An approved phase is **architecturally frozen**. Future phases must respect all frozen decisions. Any architectural change requires `docs/ARCHITECTURE_CHANGE_REQUEST.md` (reason, impact, affected modules, migration plan, risks, alternatives) approved by the owner. No silent architectural changes.

---

## 12. Task Decomposition Standard (Phase 6)

### 12.1 Principles

Every task must: have a single responsibility; be independently testable and reviewable; produce a working artifact; have deterministic acceptance criteria; avoid overlap with other tasks; expose explicit dependencies. Tasks are as small as possible while remaining meaningful. No task may require an architectural decision. If a task exceeds roughly one implementation session, split it into independently executable sub-tasks.

### 12.2 Task Template

Every task in `33_TASK_BREAKDOWN.md` follows exactly this template:

- **Task ID** — `TASK-0001` (stable, never reused)
- **Title**
- **Category** — Core | Domain | Storage | UI | Agent | Verification | Testing | Documentation | Infrastructure
- **Purpose**
- **Scope** — Included / Excluded
- **Dependencies** — Task IDs
- **Required Inputs** — specification documents
- **Produced Outputs** — every file produced
- **Public Interfaces** — created or modified
- **Implementation Constraints** — what MUST NOT change
- **Required Capability** — capability profile only, never a model name
- **Estimated Complexity** — XS | S | M | L | XL
- **Estimated Context Size** — Tiny | Small | Medium | Large
- **Parallelizable** — Yes | No
- **Local Eligibility** — `LOCAL_SAFE` | `CLOUD_REQUIRED` (§12.4)
- **Acceptance Criteria** — objectively testable
- **Verification** — Compiler | Unit Tests | Snapshot | Visual | Schema | Static Analysis | Benchmark
- **Deliverables**
- **Definition of Done**
- **Risks**
- **Future Extension Points**

### 12.3 Execution Waves

`36_TASK_EXECUTION_ORDER.md` groups tasks into waves (e.g. Foundation → Core Engine → Domain Features → Integration → Verification → Documentation). Each wave must compile and run independently.

### 12.4 Local LLM Eligibility

- `LOCAL_SAFE`: pure implementation, pure functions, small modules, utility classes, parsers, serialization, testing, documentation, refactoring.
- `CLOUD_REQUIRED`: architecture, API design, cross-module refactoring, public interfaces, complex algorithms, security decisions, performance strategy.

### 12.5 Implementation Queue

`queue/IMPLEMENTATION_QUEUE.json` entries carry: task ID, dependencies, priority, capability requirement, complexity, estimated context, local-safe flag, verification method, ready status — directly consumable by any orchestration system with no additional architectural interpretation.

---

## 13. Final Requirement

The completed package must behave like an internal engineering design package of a large software organization:

- Any capable implementation agent can implement modules without redesigning them.
- Any reviewer agent can review without asking architectural questions.
- Local LLMs can execute isolated micro-tasks using only the generated specifications.
- The architecture remains stable even as underlying models change.

Model-agnostic. Capability-driven. Deterministic where possible. Built for long-term maintenance.
