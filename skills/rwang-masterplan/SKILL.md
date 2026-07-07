---
name: rwang-masterplan
description: RWANG:MasterPlan — universal architecture-first multi-agent project protocol. Use when the user says "RWANG:MasterPlan", "RWANG MasterPlan", "อ่าน MasterPlan", "เริ่มโปรเจกต์", "ทำต่อ" in a RWANG project, invokes /rwang-masterplan, or asks to bootstrap or continue an architecture-first / spec-driven project in any directory. Installs RWANG-MASTERPLAN.md into the project if missing, then executes its Bootstrap Protocol.
---

# RWANG:MasterPlan Bootstrap

This skill runs RWANG:MasterPlan in the current working directory. The canonical `RWANG-MASTERPLAN.md` lives in this skill's directory. It is part of the **RWANG:** command family — sibling skills follow the same pattern (`rwang-<module>` on disk, `RWANG:<Module>` in conversation).

## Steps

1. **Install RWANG into the project if missing** (makes it usable by any agent, not just Claude Code).
   - For each of `RWANG-MASTERPLAN.md`, `RWANG-CORE.md`, `RWANG-REVIEW.md`, `RWANG-OPTIMIZE.md`, `RWANG-VERSION.md`: if the project root lacks it, copy it from this skill's directory. Never overwrite an existing copy — the project's copy is authoritative.
   - If the project root has no `AGENTS.md`, copy `AGENTS.md` from this skill's directory (the RWANG command-dispatch table that Codex/Cursor/other agents auto-load).
   - If the project root has no `CLAUDE.md`, copy `CLAUDE.md` from this skill's directory.
   - Never create or overwrite `README.md` — it is reserved for the project's human-facing readme.
   - If a bundled file is absent from this skill's directory, fetch it from https://github.com/Freshair129/RWANG-PROMAX.

2. **Read the project's `RWANG-MASTERPLAN.md` in full.** The copy in the project — not this skill — is the source of truth for all rules.

3. **Execute §1 Bootstrap Protocol exactly as written:**
   - Inventory the repository (`state/PROJECT_STATE.json`, `project/`, `docs/`, `queue/`).
   - Resolve the current phase from the state file (initialize it if absent).
   - Resolve the project definition from `project/` and root-level owner materials.
   - Execute the current phase; stop only at the MasterPlan's defined stop points.

4. **Stop points (the only ones):**
   - Phase completed → write `docs/PHASE_<N>_REVIEW.md`, set state to `awaiting_approval`, summarize to the owner, stop.
   - No project materials exist anywhere → ask the owner the single allowed question: "What should this project be?"

## Rules

- Respect all RWANG rules: architect agents never write production code (Phases 0–6); frozen phases require an `ARCHITECTURE_CHANGE_REQUEST.md`; the owner is the only approval authority.
- If the project's `RWANG-MASTERPLAN.md` and this skill's copy differ, the project's copy wins for that project.
