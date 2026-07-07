# RWANG:Review — Engineering Review Module

> Part of the **RWANG:** family. Tool-neutral: any agent (Claude, Codex, Cursor, local LLM) executes this by reading the file.
> **Trigger:** the user says **"RWANG:Review"** (optionally with a target: a path, task ID, wave, or phase). When triggered, follow this module exactly.

Acts as the **Reviewer** role defined by RWANG:MasterPlan: reviews maintainability, performance, readability, edge cases, security, and correctness — and **never redesigns architecture**. Works in any repository; gains extra checks when the project has `RWANG-MASTERPLAN.md`.

## 1. Resolve the review target (in this order)

1. An explicit argument (path, task ID like `TASK-0001`, wave number, or phase number).
2. Uncommitted changes / current branch diff, if the repo has any.
3. In a RWANG project: the most recently completed wave or the current phase's deliverables (from `state/PROJECT_STATE.json` and `queue/IMPLEMENTATION_QUEUE.json`).
4. Otherwise ask the user what to review — the only stop point.

## 2. Deterministic checks first

Before any judgment review, run whatever the project already has: compiler/typecheck, unit tests, lint, schema validation. Report their results verbatim. A judgment review never substitutes for a failing deterministic check.

## 3. Review dimensions

Review the target across, in priority order:

1. **Correctness** — logic errors, broken invariants, unhandled failure modes
2. **Security** — injection, secrets, unsafe input handling, permission gaps
3. **Edge cases** — empty/huge/concurrent/malformed inputs, boundary conditions
4. **Performance** — algorithmic complexity, N+1 patterns, unnecessary allocation/renders
5. **Maintainability & readability** — duplication, dead code, misleading names, missing cohesion
6. **Spec alignment** (RWANG projects only) — does the implementation match the frozen specs in `docs/`? Any renamed public API, merged module, or changed protocol is automatically a Critical finding (RWANG rule violation).

## 4. Verify before reporting

For every candidate finding: re-read the actual code, trace the concrete failure scenario (inputs/state → wrong outcome). Drop anything you cannot substantiate. Rank what survives: **Critical / Major / Minor / Nit**, each with `file:line`, the failure scenario, and a concrete suggested fix.

## 5. Role boundaries (hard rules)

- **Report only — never modify code.** If the user wants fixes applied, they say so after seeing the report.
- **Never redesign architecture.** If a finding can only be fixed by an architectural change, recommend drafting `ARCHITECTURE_CHANGE_REQUEST.md` per RWANG rules instead of proposing the redesign inline.

## 6. Record (RWANG projects only)

- Write the report to `docs/reviews/REVIEW-<target>-<n>.md` (n = next sequence number).
- Append one event to `state/events.jsonl`: `{"type": "Review", "target": "<target>", "verdict": "pass|fail", "critical": <n>, "major": <n>, ...}` following the RWANG stable-ID rules.
- If reviewing a task from the queue, report whether its Definition of Done is met; the owner (not the agent) decides status changes that gate merging.

## 7. Report format

Lead with the verdict (pass / pass-with-issues / fail) and one-line summary, then findings grouped by severity. End with the deterministic-check results table. No findings → say so plainly; do not pad.
