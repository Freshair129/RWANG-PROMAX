---
name: rwang-quickstart
description: RWANG:QuickStart — make the current project fully RWANG-ready in one shot by running three sibling modules in order (Core → Version → MasterPlan). Use when the user says "RWANG:QuickStart", "quick start", invokes /rwang-quickstart or $rwang-quickstart, or asks to set up / initialize / kick off a project with RWANG in one command. Part of the RWANG: command family.
---

# RWANG:QuickStart

One command = three sibling skills, in this exact order. **Do not copy any module file into the project** — modules are read from the installed skills (SSOT: `~/.agents/skills`); the project receives only its own artifacts.

1. **Core** — read the `rwang-core` skill's `RWANG-CORE.md`: rules R1–R6 are now in effect for everything below.
2. **Version** — per the `rwang-version` skill's `RWANG-VERSION.md`: `git init` if the folder is not a repo, install the write gate (`pre-commit`), create the `.rwang/` sidecar registry, and `register` all owner materials (root spec files and `project/` if present) so drift detection is active from day one.
3. **MasterPlan** — per the `rwang-masterplan` skill's `RWANG-MASTERPLAN.md`: execute the Bootstrap Protocol — initialize `state/PROJECT_STATE.json`, create `docs/ state/ queue/ src/`, resume or enter Phase 0, and **stop at the first approval gate** as the protocol demands.

Finish with a readiness checklist: what was created, what was found and left untouched (never overwrite existing files, never touch `README.md`), current phase, and the suggested next step.

If no owner materials exist anywhere, ask the single allowed question — "What should this project be?" — before step 3.
