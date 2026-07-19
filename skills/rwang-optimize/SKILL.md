---
name: rwang-optimize
description: RWANG measured, architecture-preserving implementation optimization. Use when the user says RWANG:Optimize, invokes /rwang-optimize or $rwang-optimize, or asks to optimize speed, memory, bundle size, queries, rendering, or private implementation complexity.
version: 1.1.0
---

# RWANG Optimize

Read `RWANG-OPTIMIZE.md` in full; it is this skill's SSOT.

Resolve the target and metric, measure a baseline, rank candidates by impact/effort, then change one thing at a time. After each change, run tests and re-measure. Keep only measured improvements or an explicit size/readability gain; revert neutral or regressive experiments.

Never change approved architecture, public APIs, module boundaries, protocols, schemas, or folder structure. If the best optimization requires that boundary, stop and request an owner-approved Architecture Change Request.

## Changelog

| Version | Date | Change |
|---|---|---|
| 1.1.0 | 2026-07-19 | Added the missing bundled SSOT and aligned constraints with Design Gates and Execution. |
