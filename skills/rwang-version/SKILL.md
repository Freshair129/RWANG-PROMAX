---
name: rwang-version
description: RWANG:Version — SemVer version control via non-invasive sidecar registry with drift audit and a commit write-gate. Use when the user says "RWANG:Version", "RWANG Version", invokes /rwang-version, or asks to version documents/code, bump a version, register files in a version registry, audit whether recorded versions match actual files, or set up a write gate. Actions: (none)=audit, register <path>, bump <path> [major|minor|patch] "<reason>", fix. Part of the RWANG: command family.
---

# RWANG:Version

Execute the RWANG:Version module. **The SSOT is `RWANG-VERSION.md` in this skill's directory** — read it in full and follow it exactly. Never copy module files into the project (legacy exception: a project's own copy wins there).

1. Parse the user's action: no action → **audit** (read-only); or `register` / `bump` / `fix` as defined in the module.
2. All metadata lives in the project's `.rwang/` sidecar (`registry.json` index + `meta/<path>.json` per file with changelog — skeletons in this skill's `templates/`). **Never write into a registered original file.** Compute real sha256 hashes — never guess.
3. If the project is a git repo and `.git/hooks/pre-commit` is absent, install the write gate from this skill's bundled `pre-commit` (chmod +x) and tell the user. If a hook already exists, tell the user to merge manually — do not overwrite.
4. Hard rules: audit never modifies anything; MAJOR bump on a frozen (`beta`/`stable`) item requires an approved `ARCHITECTURE_CHANGE_REQUEST.md` cited in the changelog ref; `fix` lists every correction before applying and never invents versions; never bypass the gate with `--no-verify`.
5. In MasterPlan projects, log every operation to `state/events.jsonl` and run an audit before any phase-approval request.
