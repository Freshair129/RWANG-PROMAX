---
name: rwang-review
description: RWANG read-only engineering review for a diff, module, task, Execution wave, or Design Gate. Use when the user says RWANG:Review, invokes /rwang-review or $rwang-review, or asks for correctness, security, edge-case, performance, maintainability, or approved-spec alignment review.
version: 1.1.0
---

# RWANG Review

Read `RWANG-REVIEW.md` in full; it is this skill's SSOT. Use `templates/REVIEW.md` for the report.

## Target resolution

1. Explicit path/task/wave/gate.
2. Uncommitted/current-branch diff.
3. Latest Execution wave or current Design Gate from project state/queue.
4. Otherwise ask what to review.

Run project build/typecheck, tests, lint, schema, and relevant smoke checks before judgment review. Report results verbatim.

Verify each finding by tracing a concrete failure scenario. Rank Critical, Major, Minor, or Nit with tight `file:line` evidence and a concrete fix direction. Report only; never modify code or redesign architecture. Architecture changes require an owner-approved change request.

## Changelog

| Version | Date | Change |
|---|---|---|
| 1.1.0 | 2026-07-19 | Added the missing bundled SSOT and aligned review targets with Design Gates and Execution. |
