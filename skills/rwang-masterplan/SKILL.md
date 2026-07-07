---
name: rwang-masterplan
description: RWANG:MasterPlan — universal architecture-first multi-agent project charter. Use when the user says "RWANG:MasterPlan", "RWANG MasterPlan", "อ่าน MasterPlan", "อ่าน CHARTER" or "อ่าน README" (legacy phrasing), "เริ่มโปรเจกต์", "ทำต่อ" in a MasterPlan project, invokes /rwang-masterplan, or asks to bootstrap or continue an architecture-first / spec-driven project in any directory. Installs RWANG-MASTERPLAN.md into the project if missing, then executes its Bootstrap Protocol.
---

# RWANG:MasterPlan Bootstrap

This skill runs the RWANG:MasterPlan charter in the current working directory. The canonical charter lives in this skill's directory as `RWANG-MASTERPLAN.md`. It is part of the **RWANG:** command family — sibling skills follow the same pattern (`rwang-<module>` on disk, `RWANG:<Module>` in conversation).

## Steps

1. **Install the charter if missing.**
   - If the project root has no `RWANG-MASTERPLAN.md`, copy `RWANG-MASTERPLAN.md` from this skill's directory into the project root. Never overwrite an existing copy — the project's copy is authoritative for that project.
   - If the project root has no `CLAUDE.md`, create it with exactly: `Read RWANG-MASTERPLAN.md and execute its Bootstrap Protocol immediately.`
   - If the project root has no `AGENTS.md`, create it with the same one line (so non-Claude agents bootstrap too).
   - Never create or overwrite `README.md` — it is reserved for the project's human-facing readme.
   - Legacy projects: if the root has `CHARTER.md` from an older version, rename it to `RWANG-MASTERPLAN.md` and update the pointer files.

2. **Read the project's `RWANG-MASTERPLAN.md` in full.** The charter in the project — not this skill — is the source of truth for all rules.

3. **Execute §1 Bootstrap Protocol exactly as written:**
   - Inventory the repository (`state/PROJECT_STATE.json`, `project/`, `docs/`, `queue/`).
   - Resolve the current phase from the state file (initialize it if absent).
   - Resolve the project definition from `project/` and root-level owner materials.
   - Execute the current phase; stop only at the charter's defined stop points.

4. **Stop points (the only ones):**
   - Phase completed → write `docs/PHASE_<N>_REVIEW.md`, set state to `awaiting_approval`, summarize to the owner, stop.
   - No project materials exist anywhere → ask the owner the single allowed question: "What should this project be?"

## Rules

- Respect all charter constraints: architect agents never write production code (Phases 0–6); frozen phases require an `ARCHITECTURE_CHANGE_REQUEST.md`; the owner is the only approval authority.
- If the project's `RWANG-MASTERPLAN.md` and this skill's copy differ, the project's copy wins for that project.
