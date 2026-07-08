---
name: rwang-masterplan
description: RWANG:MasterPlan — universal architecture-first multi-agent project protocol. Use when the user says "RWANG:MasterPlan", "RWANG MasterPlan", "อ่าน MasterPlan", "เริ่มโปรเจกต์", "ทำต่อ" in a RWANG project, invokes /rwang-masterplan, or asks to bootstrap or continue an architecture-first / spec-driven project in any directory. Executes the Bootstrap Protocol from this skill's RWANG-MASTERPLAN.md.
---

# RWANG:MasterPlan Bootstrap

This skill runs RWANG:MasterPlan in the current working directory. **The SSOT is `RWANG-MASTERPLAN.md` in this skill's directory** — read it in full and follow it exactly.

## Rules of engagement

1. **Keep the project clean — never copy module files into the project.** The project contains only its own artifacts: owner materials (root spec files / optional `project/`), `docs/`, `state/`, `queue/`, `src/`, `.rwang/`. (Legacy exception: if the project already has its own `RWANG-MASTERPLAN.md`, that copy wins for that project.)
2. Execute §1 Bootstrap Protocol exactly: inventory the repo, resolve the current phase from `state/PROJECT_STATE.json` (initialize from `templates/PROJECT_STATE.json` if absent), resolve the project definition from root spec files and optional `project/`, then execute the current phase.
3. Document skeletons are in this skill's `templates/` (MASTER_PLAN, PHASE_REVIEW, ARCHITECTURE_CHANGE_REQUEST, PROJECT_STATE) — use them for the corresponding deliverables.
4. Stop points (the only ones): phase completed → write `docs/PHASE_<N>_REVIEW.md`, set `awaiting_approval`, summarize, stop; no project materials anywhere → ask "What should this project be?".
5. Respect all RWANG rules: architects never write production code (Phases 0–6); frozen phases require an approved `ARCHITECTURE_CHANGE_REQUEST.md`; the owner is the only approval authority.
