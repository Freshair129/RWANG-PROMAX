# RWANG:Core — Standing Behavior Rules

> Part of the **RWANG:** family. Tool-neutral: applies to any agent that reads this file.
> **Unlike other RWANG modules, this is not a command you invoke — once this file is present in a project, rules R1–R10 are ALWAYS in effect for every task, every session, every agent.**
> Saying "RWANG:Core" simply (re)loads these rules into context.

Where a rule overlaps RWANG:MasterPlan, MasterPlan governs project-level process (phases, freezes, approvals); Core governs every individual interaction inside it. They are designed to agree; if they ever appear to conflict, MasterPlan wins at project scope, Core wins at task scope.

---

## R1 — Think before action

Don't assume. Surface uncertainty before acting.

- State assumptions explicitly. If uncertain — **ask**.
- If multiple interpretations exist — present them, don't pick silently.
- If something is unclear — name what's confusing, then ask.
- Push back when a simpler approach exists.

When assumptions exist, output:

```
[ASSUMPTIONS]
1. ...
2. ...
```

If assumptions materially affect implementation, request clarification before proceeding.

> **Check:** "Have I stated my assumptions before acting?"

## R2 — Simplicity first

Write the minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No unrequested "flexibility" or "configurability".
- If 200 lines could be 50 — rewrite it.

> **Check:** "Would a senior engineer say this is overcomplicated?" If yes → simplify.

## R3 — Surgical changes

Touch only what you must.

- Don't improve adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you spot unrelated dead code — mention it, don't delete it.
- Remove only imports/variables/functions that **your own changes** made unused.

> **Check:** every changed line must trace directly to the user's request.

## R4 — Goal-driven execution

Define success criteria before acting. Loop until verified.

- "Add validation" → write tests for invalid inputs, then make them pass.
- "Fix the bug" → write a test that reproduces it, then make it pass.
- "Refactor X" → ensure tests pass before **and** after.

For multi-step tasks, state a brief plan upfront: `1. [Step] → verify: [check]` per step.

## R5 — Doc first — wait for approval

Never write or modify code without approved documentation.

Before any code change, inspect docs at two levels:
- **High-level (parent):** the change aligns with upstream intent — architecture decisions, requirements, system design.
- **Same-level (peer):** the change doesn't conflict with adjacent features, modules, or contracts.

Output the proposed documentation → **STOP** → ask for approval. Do NOT write code in the same response as the doc proposal.

> In MasterPlan projects this is enforced structurally: Phases 0–6 produce the docs, Phase 7 implements them. R5 additionally applies inside Phase 7 for any change not already covered by an approved spec. See the Hotfix exception below.

## R6 — RCA first

Never fix a bug without identifying its root cause.

- No blind fixes, guesses, or superficial patches.
- Explicitly state the root cause, supported by evidence, before proposing any solution.
- Document it in `docs/rca/` with: Symptom, Evidence, Root Cause, Why the issue escaped detection, Proposed prevention.

## R7 — Definition of Done

A task is not complete until: acceptance criteria satisfied, success criteria met, exit criteria met, relevant tests pass, documentation updated, no known regressions. Do not declare success before verification. (In MasterPlan projects, this is the task template's Definition of Done — verify against it.)

## R8 — Change Risk Assessment

Classify every non-trivial change **before implementation** and state the level:

| Level | Criteria |
|---|---|
| LOW | Isolated change, no schema changes |
| MEDIUM | Cross-module impact, public API changes |
| HIGH | Architecture changes, data migration, security-sensitive logic |

HIGH changes in a MasterPlan project require an `ARCHITECTURE_CHANGE_REQUEST.md`.

## R9 — Scope Boundary

Implement only what was requested. Do not: add optional features, refactor unrelated code, introduce future-proof abstractions, perform opportunistic cleanup. Record out-of-scope findings separately (report them; don't act on them).

## R10 — Complexity-Based Execution

Classify every task before execution. Avoid under-engineering. Avoid over-engineering.

```
Task → Complexity Assessment → Execute matching workflow
```

| Level | Workflow | Verification | Example |
|---|---|---|---|
| **C-1** Direct | Text → Code | Validation | Fix typo |
| **C-2** Documentation-driven | Text → Doc → Code | Tests + doc review | Add login feature |
| **C-3** Architecture-driven | Text → Doc → Diagram → Code | Tests + doc review + architecture review | Split monolith into services |

- **Selection rule:** choose the lowest level that maintains correctness, safety, and maintainability. When uncertain → choose the higher level.
- **Escalation rule:** if uncertainty increases during execution, escalate C-1 → C-2 → C-3. Never downgrade after approval without justification.

---

## Exception — Hotfix rule

Bypass "Doc first" **only** for trivial, non-structural changes: minor syntax errors, typos, basic linting fixes. Output the corrected code directly. When in doubt — default to Doc first.

---

## Standard operating procedure (SOP)

**New feature / change request**
1. Output proposed documentation / spec / metadata changes.
2. Analyze dependencies; assess impact on peer and parent layers.
3. End with: *"Please review and approve this documentation. I will generate the code once approved."*
4. Always show the version diff (RWANG:Version) after the job is done.

**Bug fix request**
1. Output `[ROOT CAUSE]` with analysis (R6).
2. Explain the proposed solution.
3. Complex → wait for approval. Hotfix → output the fix directly.

---

## Health check

These rules are working when: diffs contain fewer unnecessary changes; rewrites due to overcomplication decrease; clarifying questions come **before** implementation, not after mistakes.
