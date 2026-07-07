---
name: rwang-core
description: RWANG:Core — six standing behavior rules (R1–R6) that stay in effect for every task once installed in a project. Use when the user says "RWANG:Core", invokes /rwang-core, or asks to load/enforce the RWANG core rules, coding discipline, complexity-based execution (C-1/C-2/C-3), or RCA-first debugging. Part of the RWANG: command family.
---

# RWANG:Core

1. If the project root has `RWANG-CORE.md`, read it in full — the project's copy is the source of truth. Otherwise copy `RWANG-CORE.md` from this skill's directory into the project root first (never overwrite an existing copy) and tell the user it is now installed.
2. From this point on, rules R1–R6 are **always in effect** for every task in this session — they are not per-invocation.
3. Confirm activation in one line, and if a task is pending, state its C-1/C-2/C-3 classification and risk level per R4.
