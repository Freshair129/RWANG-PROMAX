# RWANG:Init — One-Command Project Onboarding

> Part of the **RWANG:** family. Tool-neutral: any agent (Claude, Codex, Antigravity, Cursor, local LLM) executes this by reading the file.
> **Trigger:** the user says **"RWANG:Init"**, optionally with a depth: `setup` (default) | `plan` | `docs`. When triggered, follow this module exactly.

One command that takes a folder from zero to ready — structure, governance, and (optionally) the entire documentation stage.

## 1. Depth levels

| User says | Outcome | Stops |
|---|---|---|
| `RWANG:Init` | Structure + governance installed — project ready to use | Immediately (nothing architectural was decided, so nothing needs approval) |
| `RWANG:Init plan` | Setup + execute **Phase 0** (MASTER_PLAN.md + discovery docs) | At the Phase 0 approval gate |
| `RWANG:Init docs` | Setup + run **Phases 0–6 consecutively** until the docs are ready-to-code | Before Phase 7 (implementation) — one consolidated ratification |

## 2. Setup (all modes)

Idempotent — **never overwrite anything that exists**; if the project is already initialized, report its status instead.

1. **Modules** — ensure `RWANG-MASTERPLAN.md`, `RWANG-CORE.md`, `RWANG-REVIEW.md`, `RWANG-OPTIMIZE.md`, `RWANG-VERSION.md`, `RWANG-INIT.md`, `AGENTS.md`, `CLAUDE.md` exist at the project root (copy from this skill's directory / `~/.rwang` / https://github.com/Freshair129/RWANG-PROMAX).
2. **Structure** — create `docs/`, `state/`, `queue/`, `src/`. Do NOT create `project/` (optional, owner's choice) and never touch `README.md`.
3. **Governance**
   - `git init` if not a repo, then install the write gate (`gate/pre-commit` → `.git/hooks/pre-commit`).
   - `.gitignore` — ensure entries: `.brain/`, `node_modules/`, `state/*.jsonl` stays tracked or not per owner preference (default: tracked).
   - Initialize `state/PROJECT_STATE.json` (`current_phase: 0`, `phase_status: "not_started"`).
   - Run `RWANG:Version register` on all owner materials (creates `.rwang/` sidecars) so drift detection is active from day one.
   - RWANG:Core rules R1–R6 are now in effect.
4. **Inventory** owner materials (root spec files and/or `project/`). If none exist anywhere, ask the single allowed question: *"What should this project be?"*
5. **Report** a readiness checklist (what was added, what was kept) and the suggested next command.

## 3. `plan` mode

After setup, execute the MasterPlan Bootstrap Protocol → Phase 0: produce `docs/MASTER_PLAN.md` and the discovery deliverables, write `docs/PHASE_0_REVIEW.md`, set `awaiting_approval`, summarize, **stop**. Normal gate rules apply from here.

## 4. `docs` mode — express run to "ready to code"

Invoking `docs` is the owner's **explicit blanket pre-approval for the design phases (0–6) to run consecutively**. The discipline is preserved by these rules:

1. Every phase still produces its full deliverables **and** its `PHASE_<N>_REVIEW.md` — nothing is skipped, only the waiting is.
2. All outputs carry status **`candidate`** (via RWANG:Version) — **nothing freezes during the run**.
3. R1 still applies: if the agent hits a decision it cannot make without the owner (genuinely ambiguous scope, conflicting requirements), it **pauses and asks** — express mode is not permission to invent silently.
4. At the end, produce `docs/CONSOLIDATED_REVIEW.md`: every major decision, every tradeoff, every risk, phase by phase, with links.
5. **Hard stop before Phase 7.** Present the consolidated review. Only when the owner explicitly ratifies ("อนุมัติ"/"approve") do all phase docs get bumped to `1.0.0` / frozen — and only then may implementation begin. The no-code-without-approval gate is never waived.
6. If the owner rejects parts: fix those phases (still `candidate`), re-present. Rejected work never needs an `ARCHITECTURE_CHANGE_REQUEST` because nothing was frozen yet.

## 5. Relationship to other modules

- `RWANG:Init` prepares; **RWANG:MasterPlan** governs everything after (resume, gates, phases).
- The shell scripts `rwang-init.sh`/`.ps1` are the dumb file-copy fallback for agents with no skill system — this module is the full, intelligent version.
