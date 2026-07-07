---
name: rwang-core
description: RWANG:Core — standing behavior rules (R1–R10) that stay in effect for every task once installed in a project. Use when the user says "RWANG:Core", invokes /rwang-core, or asks to load/enforce the RWANG core rules, coding discipline, doc-first workflow, RCA-first debugging, or complexity-based execution (C-1/C-2/C-3). Part of the RWANG: command family.
---

# RWANG:Core

1. If the project root has `RWANG-CORE.md`, read it in full — the project's copy is the source of truth. Otherwise copy `RWANG-CORE.md` from this skill's directory into the project root first (never overwrite an existing copy) and tell the user it is now installed.
2. From this point on, rules R1–R10, the Hotfix exception, and the SOPs are **always in effect** for every task in this session — they are not per-invocation.
3. Confirm activation with a one-line summary of the rules and the current task's complexity classification (C-1/C-2/C-3) if a task is pending.
