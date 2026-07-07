# RWANG:Version — Version Control, Registry & Write Gate Module

> Part of the **RWANG:** family. Tool-neutral: any agent (Claude, Codex, Cursor, local LLM) executes this by reading the file.
> **Trigger:** the user says **"RWANG:Version"**, optionally followed by an action. When triggered, follow this module exactly.

Gives every document and code artifact its own SemVer version — **without ever modifying the original files**. All metadata lives in a sidecar structure that mirrors the original paths; drift is detected by content hashing; ungated writes are blocked at commit time.

## 1. Actions

One command, four actions. With no action given, default to **audit** (read-only — never modifies anything).

| User says | Action |
|---|---|
| `RWANG:Version` | Audit + status report (read-only) |
| `RWANG:Version register <path...>` | Add file(s)/folder(s) to the registry |
| `RWANG:Version bump <path> [major\|minor\|patch] "<reason>"` | Bump a version (reason required) |
| `RWANG:Version fix` | Apply the corrections proposed by the most recent audit, listing each one before applying |

## 2. Sidecar layout — originals are never touched

Original files keep their names, their content, and their format. RWANG:Version adds only:

```
.rwang/
├─ registry.json                     ← thin central index (id, path, version, status per item)
├─ meta/
│  └─ <original path>.json           ← one sidecar per registered file, mirroring its path
│     e.g. .rwang/meta/docs/ARCHITECTURE.md.json  →  points to docs/ARCHITECTURE.md
└─ (gate hook installed into .git/hooks/pre-commit — see §7)
```

**Hard rule: this module never writes into a registered original file — no frontmatter, no footers, no markers.** Everything lives in the sidecar.

### Sidecar file format

```json
{
  "id": "DOC-0001",
  "points_to": "docs/ARCHITECTURE.md",
  "type": "doc | code | config",
  "version": "1.2.0",
  "status": "draft | candidate | beta | stable | unstable | deprecated | superseded",
  "superseded_by": null,
  "sha256": "<hash of the original file's content at last register/bump>",
  "relations": { "depends_on": ["DOC-0002"], "referenced_by": [] },
  "attributes": { "doc_type": "spec", "domain": "..." },
  "created_at": "<ISO-8601 with local offset, e.g. +07:00>",
  "updated_at": "<ISO-8601 with local offset>",
  "changelog": [
    { "version": "1.2.0", "date": "<ISO-8601+07:00>", "kind": "minor", "change": "added event schema", "ref": "TASK-0012", "agent": "<agent id>", "commit": "<git short hash or null>" },
    { "version": "1.1.0", "date": "<ISO-8601+07:00>", "kind": "minor", "change": "initial freeze follow-up", "ref": "PHASE-2", "agent": "<agent id>", "commit": "<git short hash or null>" }
  ]
}
```

- The **changelog is the file's footer/history** — newest first, one entry per bump, never rewritten.
- `relations` entries (maintained at register/bump time) let any tool build a lightweight dependency **graph map** across sidecars without parsing the originals.
- IDs follow RWANG stable-ID rules: `DOC-xxxx` / `SRC-xxxx` / `CFG-xxxx`, never regenerated, never derived from filenames.
- `registry.json` is the machine-first index; on any conflict between it and a sidecar, fix toward the sidecar's changelog history and log the correction.

## 3. SemVer semantics (x.y.z)

| Segment | Meaning | Rule |
|---|---|---|
| `0.y.z` | Draft | The owning phase is not yet approved |
| `→ 1.0.0` | Approved | Set automatically when the phase is approved; status becomes `beta` |
| **MAJOR (x)** | Breaking: structural change, rule/section removed or renamed, SOP restructured | On a `beta`/`stable` item this REQUIRES an approved `ARCHITECTURE_CHANGE_REQUEST.md` — cite it in the changelog `ref` or refuse the bump |
| **MINOR (y)** | Additive: new rule/section, SOP step added, backward-compatible content | Allowed with owner awareness |
| **PATCH (z)** | Clarification, typo, formatting, no change in meaning | Freely allowed |
| `-beta` | Pre-release suffix (standard SemVer), e.g. `1.1.0-beta` | Optional for items published before their gate; spoken shorthand "1.1.0b" is accepted in conversation but stored as `-beta` |

### Status lifecycle (one dimension, one direction)

```
draft → candidate → beta → stable
                      ↘ unstable (known issues — must return to beta/stable or be rolled back)
any → deprecated | superseded (terminal; superseded requires superseded_by)
```

- `draft` — being written, phase not approved. `candidate` — proposed for approval.
- `beta` — approved, in soak/testing. `stable` — proven in use or promoted by the owner. **Both `beta` and `stable` count as "frozen" in MasterPlan terms** — the MAJOR/change-request rule applies to both.
- **Rollbacks are events, not identities.** Never encode rollback into the version string (no `r`/`f` suffixes): record a changelog entry with `kind: "rollback"` or `"rollback-fix"` citing the version reverted to, bump PATCH, and set status `unstable` until re-verified.
- Review pressure is not a lifecycle state: an item under review keeps its status; review findings live in `docs/reviews/` (RWANG:Review) and the audit report.

## 4. Audit checks (in order)

1. **Orphan sidecars** — sidecar exists but the original file is gone.
2. **Unregistered files** — files in governed scopes (`docs/`, `src/`, `queue/`) with no sidecar.
3. **Unbumped edits** — original's current sha256 ≠ sidecar sha256 while the version is unchanged. **This is exactly "someone changed the source without updating the version"** — flag as Critical, name the file, show the last changelog entry so the owner sees where history stopped.
4. **Index drift** — `registry.json` disagrees with a sidecar (version/status/path).
5. **Rule violations** — invalid SemVer, duplicate IDs, a `frozen` item still at `0.y.z`, MAJOR on frozen without a cited change request, or a changelog whose latest entry doesn't match the current version.

Report as a table: ✅ in sync / ⚠️ drift / ❌ violation, with the exact fix each item needs. The audit itself changes nothing; corrections happen only via `fix` (or explicit `register`/`bump`), and `fix` never invents versions — where intent is ambiguous it asks the owner or proposes the smallest bump, and always appends a changelog entry explaining the correction.

## 5. Record

Every operation appends a changelog entry in the affected sidecar. In MasterPlan projects, additionally append one event per operation to `state/events.jsonl`: `{"type": "VersionRegister" | "VersionBump" | "VersionAudit" | "VersionFix", ...}`. Audits log summary counts even when clean.

## 6. Integration with RWANG:MasterPlan

- **Phase completion** → register that phase's new deliverables at `0.1.0` (status `draft`).
- **Phase approval** → bump all of that phase's deliverables to `1.0.0` (status `frozen`) in the same step that updates `PROJECT_STATE.json`.
- **Phase 7 tasks** → when a task completes, register/bump its produced files, citing `TASK-xxxx` in the changelog `ref`.
- Run an audit before every phase-approval request; report drift to the owner alongside `PHASE_<N>_REVIEW.md`.

Standalone (non-MasterPlan) repositories work identically — freeze semantics simply don't apply until the owner declares an item frozen.

## 7. Write Gate — how ungated writes are stopped

Instructions alone cannot force an agent to obey. RWANG therefore makes an ungated write **unable to land and unable to hide**, in layers:

**Layer 1 — Commit gate (universal, enforced by git itself).**
`rwang-init` installs `gate/pre-commit` into `.git/hooks/pre-commit`. On every commit it checks each staged registered file:
- its sidecar `.rwang/meta/<path>.json` must be staged in the same commit, and
- the sidecar's `sha256` must match the staged content of the original.

If either fails, **the commit is rejected** with the exact `RWANG:Version bump` command to run. This works for any agent and any tool, because everything lands through git. Bypassing with `--no-verify` is forbidden by RWANG rules — and pointless, because Layer 2 catches it.

**Layer 2 — Audit checkpoints (universal, always catches what slipped through).**
Run the audit: at Bootstrap (MasterPlan step 1), before every phase-approval request, and before any merge. Unbumped-edit drift **blocks the gate** — the owner refuses approval until the history is corrected via `RWANG:Version fix`. Hashes make hiding impossible.

**Layer 3 — Harness hooks (optional, strongest, per-tool).**
Where the agent harness supports real enforcement, add it: e.g. Claude Code PreToolUse hooks can deny `Edit`/`Write` on paths whose sidecar says `frozen` unless an approved change request exists. Equivalent mechanisms in other tools may be used when available. This layer is a bonus — Layers 1–2 are the guarantee.

Optionally, mark `frozen` originals read-only on disk as friction against accidental edits.
