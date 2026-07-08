---
name: rwang-init
description: RWANG:Init — one command that makes a project RWANG-ready. Use when the user says "RWANG:Init", "rwang init", invokes /rwang-init, or asks to set up / initialize / scaffold a project with RWANG, or to generate all design docs until ready-to-code. Depths: (none)=structure+governance ready now; "plan"=also run Phase 0 to its approval gate; "docs"=run Phases 0–6 consecutively (owner's blanket pre-approval for design phases) ending in one consolidated ratification before any code. Part of the RWANG: command family.
---

# RWANG:Init

1. If the project root has `RWANG-INIT.md`, read it in full and follow it exactly — the project's copy is the source of truth. Otherwise copy `RWANG-INIT.md` from this skill's directory into the project root first (never overwrite an existing copy).
2. Parse depth from the user's words: none/`setup` → §2 only; `plan` → §2+§3; `docs` → §2+§4.
3. Execute the module. Setup is idempotent — never overwrite existing files, never touch `README.md`. All module files needed for installation are bundled in this skill's directory (fallback: `~/.rwang`, then https://github.com/Freshair129/RWANG-PROMAX).
4. Respect every stop point the module defines: `plan` stops at the Phase 0 gate; `docs` hard-stops before Phase 7 with `docs/CONSOLIDATED_REVIEW.md` and waits for the owner's ratification. Never begin implementation from this skill.
