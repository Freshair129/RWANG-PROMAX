---
name: rwang-version
description: RWANG:Version — SemVer version control via non-invasive sidecar registry with drift audit and a commit write-gate. Use when the user says "RWANG:Version", "RWANG Version", invokes /rwang-version, or asks to version documents/code, bump a version, register files in a version registry, audit whether recorded versions match actual files, or set up a write gate. Actions: (none)=audit, register <path>, bump <path> [major|minor|patch] "<reason>", fix. Part of the RWANG: command family; integrates with RWANG:MasterPlan projects but also works standalone in any repository.
---

# RWANG:Version

Execute the RWANG:Version module. The authoritative module definition lives in the project's `RWANG-VERSION.md`; this skill's copy in its own directory is the canonical fallback.

## Steps

1. If the project root has `RWANG-VERSION.md`, read it in full and follow it exactly — the project's copy is the source of truth. Otherwise copy `RWANG-VERSION.md` from this skill's directory into the project root first (never overwrite an existing copy).
2. Parse the user's action: no action → **audit** (read-only); or `register` / `bump` / `fix` as defined in the module.
3. All metadata lives in the `.rwang/` sidecar (`registry.json` index + `meta/<path>.json` per file with changelog). **Never write into a registered original file** — no frontmatter, no footers. Compute real sha256 hashes for drift detection — never guess.
4. If the project is a git repo and `.git/hooks/pre-commit` is absent, install the write gate from this skill's bundled `pre-commit` file (chmod +x) and tell the user. If a pre-commit hook already exists, tell the user to merge manually — do not overwrite.
5. Respect the module's hard rules: audit never modifies anything; MAJOR bump on a `frozen` item requires an approved `ARCHITECTURE_CHANGE_REQUEST.md` cited in the changelog ref; `fix` lists every correction before applying and never invents versions; never bypass the gate with `--no-verify`.
6. In MasterPlan projects, log every operation to `state/events.jsonl` and run an audit before any phase-approval request.
