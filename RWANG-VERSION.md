# RWANG:Version — Version Control & Registry Module

> Part of the **RWANG:** family. Tool-neutral: any agent (Claude, Codex, Cursor, local LLM) executes this by reading the file.
> **Trigger:** the user says **"RWANG:Version"**, optionally followed by an action. When triggered, follow this module exactly.

Gives every document and code artifact its own SemVer version, tracked in one central registry, and audits that the registry matches reality on disk.

## 1. Actions

One command, four actions. With no action given, default to **audit** (read-only — never modifies anything).

| User says | Action |
|---|---|
| `RWANG:Version` | Audit + status report (read-only) |
| `RWANG:Version register <path...>` | Add file(s) to the registry |
| `RWANG:Version bump <path> [major\|minor\|patch] "<reason>"` | Bump a version (reason required) |
| `RWANG:Version fix` | Apply the corrections proposed by the most recent audit, listing each one before applying |

## 2. The Registry

`state/VERSION_REGISTRY.json` — the single source of truth for versions (machine-first: on any conflict, the registry wins). Create it on first use.

```json
{
  "registry_version": "1.0.0",
  "items": [
    {
      "id": "DOC-0001",
      "path": "docs/02_SYSTEM_ARCHITECTURE.md",
      "type": "doc",
      "version": "1.0.0",
      "status": "draft | frozen | deprecated",
      "sha256": "<hash of file content at last register/bump>",
      "created_at": "<ISO-8601>",
      "updated_at": "<ISO-8601>"
    }
  ]
}
```

- IDs follow RWANG stable-ID rules: `DOC-xxxx` / `SRC-xxxx` / `CFG-xxxx`, never regenerated, never derived from filenames.
- Markdown docs also carry `version:` in YAML frontmatter for human readability; the registry remains authoritative.
- Code files are versioned in the registry only — no version headers forced into source code.

## 3. SemVer semantics (x.y.z)

| Segment | Meaning | Rule |
|---|---|---|
| `0.y.z` | Draft | The owning phase is not yet approved |
| `→ 1.0.0` | Frozen | Set automatically when the phase is approved; status becomes `frozen` |
| **MAJOR** | Breaking / architectural change | On a `frozen` item this REQUIRES an approved `ARCHITECTURE_CHANGE_REQUEST.md` — cite it in the bump reason or refuse the bump |
| **MINOR** | Additive, backward-compatible content | Allowed with owner awareness |
| **PATCH** | Typos, formatting, no change in meaning | Freely allowed |

## 4. Audit checks (in order)

1. **Orphan entries** — registered but the file no longer exists on disk.
2. **Unregistered files** — files in governed scopes (`docs/`, `src/`, `queue/`) that have no registry entry.
3. **Unbumped edits** — file's current sha256 ≠ registry sha256 while the version is unchanged. This is the most serious drift; flag as Critical.
4. **Frontmatter mismatch** — a doc's `version:` frontmatter ≠ its registry version.
5. **Rule violations** — invalid SemVer, duplicate IDs, a `frozen` item still at `0.y.z`, or a MAJOR bump on a frozen item without a cited change request.

Report as a table: ✅ in sync / ⚠️ drift / ❌ violation, with the exact fix each item needs. The audit itself changes nothing; corrections happen only via `fix` (or an explicit `register`/`bump`), and `fix` never invents versions — where intent is ambiguous (e.g. an unbumped edit could be minor or patch), it asks the owner or proposes the smallest bump.

## 5. Record (RWANG projects)

Append one event per operation to `state/events.jsonl`: `{"type": "VersionRegister" | "VersionBump" | "VersionAudit" | "VersionFix", "id": "...", "from": "x.y.z", "to": "x.y.z", "reason": "...", ...}`. Audits log summary counts even when clean.

## 6. Integration with RWANG:MasterPlan

When running inside a MasterPlan project:

- **Phase completion** → register that phase's new deliverables at `0.1.0` (status `draft`).
- **Phase approval** → bump all of that phase's deliverables to `1.0.0` (status `frozen`) in the same step that updates `PROJECT_STATE.json`.
- **Phase 7 tasks** → when a task completes, register/bump its produced files, citing the `TASK-xxxx` id in the reason.
- Run an audit before every phase-approval request; report drift to the owner alongside `PHASE_<N>_REVIEW.md`.

Standalone (non-MasterPlan) repositories work too: the registry still lives at `state/VERSION_REGISTRY.json`, freeze semantics simply don't apply until the owner declares an item frozen.
