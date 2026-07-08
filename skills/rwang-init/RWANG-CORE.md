# RWANG:Core — Standing Behavior Rules

> Part of the **RWANG:** family. Tool-neutral: applies to any agent that reads this file.
> **Not a command — once this file is present in a project, rules R1–R6 are ALWAYS in effect.** Saying "RWANG:Core" simply (re)loads them.
> Overlap policy: MasterPlan governs project scope (phases, freezes, approvals); Core governs each task inside it. Conflict → MasterPlan wins at project scope, Core at task scope.

---

## R1 — Think before action

Don't assume. Surface uncertainty before acting.

- State assumptions explicitly; if they materially affect the work, ask before proceeding:

```
[ASSUMPTIONS]
1. ...
```

- Multiple interpretations → present them, don't pick silently.
- Push back when a simpler approach exists.

## R2 — Simplicity first

Write the minimum that solves the problem. No features beyond what was asked, no abstractions for single-use code, no unrequested flexibility. If 200 lines could be 50 — rewrite.

> **Check:** "Would a senior engineer call this overcomplicated?" If yes → simplify.

## R3 — Surgical & scoped

Touch only what you must; build only what was asked.

- Don't improve adjacent code, comments, or formatting. Match existing style.
- Remove only what **your own changes** made unused.
- No opportunistic cleanup, no future-proofing. Unrelated findings (dead code, bugs) → report, don't act.

> **Check:** every changed line traces directly to the request.

## R4 — Classify before execution

Before executing, state the task's complexity and risk. Ceremony scales with the task — never more, never less.

| Level | Workflow | Verification | Example |
|---|---|---|---|
| **C-1** | Text → Code (direct — no doc needed) | Validation | Typo, small fix, lint |
| **C-2** | Text → Doc → **approval** → Code | Tests + doc review | New feature |
| **C-3** | Text → Doc → Diagram → **approval** → Code | Tests + doc + architecture review | Restructure, migration |

Risk: **LOW** (isolated) / **MEDIUM** (cross-module or public API) / **HIGH** (architecture, data migration, security) — HIGH in a MasterPlan project requires an `ARCHITECTURE_CHANGE_REQUEST.md`.

Uncertain → choose the higher level. Uncertainty grows mid-task → escalate (C-1→C-2→C-3); never downgrade after approval without justification.

## R5 — RCA first

Never fix a bug without evidence-backed root cause, stated before the fix. No blind patches. Document in `docs/rca/`: Symptom, Evidence, Root Cause, Why it escaped detection, Prevention. (Trivial C-1 slips — typos, lint — don't need an RCA file, just the stated cause.)

## R6 — Verify to done

Define success criteria before acting; loop until verified.

- "Fix the bug" → a test that reproduces it, then passes. "Refactor" → tests pass before **and** after.
- Done = criteria met + relevant tests pass + docs updated + no known regressions. (MasterPlan projects: the task's Definition of Done.) Do not declare success before verification — after the job, show the version diff (RWANG:Version) when files are registered.

---

*Working when: diffs shrink, overcomplication rewrites disappear, and clarifying questions come before mistakes — not after.*
