---
name: rwang-optimize
description: RWANG:Optimize — measured, architecture-preserving optimization. Use when the user says "RWANG:Optimize", "RWANG Optimize", invokes /rwang-optimize, or asks to optimize performance, speed, memory, bundle size, or to simplify/streamline implementation code. Optional argument: a target path, module, or metric (e.g. "startup time", "bundle"). Part of the RWANG: command family; integrates with RWANG:MasterPlan projects but also works standalone in any repository.
---

# RWANG:Optimize

Optimizes **implementation, never architecture** — the Implementation-agent boundary from the RWANG:MasterPlan charter. Every change must be justified by a measurement.

## 1. Resolve the target

1. Explicit argument (path, module, or metric).
2. Otherwise: the project's hot path — ask one question only if the goal is genuinely undecidable (speed vs memory vs size lead to different work).

## 2. Measure first — never optimize blind

- Run existing benchmarks/perf tests if the project has them.
- Otherwise establish a quick baseline appropriate to the goal: timed runs, bundle-size report, memory snapshot, query counts, profiler output.
- Record the baseline numbers. If nothing measurable can be established, say so and downgrade to a static review of algorithmic complexity — clearly labeled as unmeasured.

## 3. Identify and rank candidates

Profile or inspect to find hotspots. Rank by expected impact ÷ effort. Typical wins: algorithmic complexity, N+1 I/O, caching/memoization, unnecessary re-renders/allocations, lazy loading, dead code and duplicate logic, over-general abstractions used once (simplification counts as optimization).

## 4. Hard constraints (charter role boundaries)

MAY: optimize implementation, improve performance, improve typing, add/adjust tests, simplify private internals.
MUST NOT: redesign architecture, rename public APIs, merge modules, remove abstraction layers, change communication protocols, change folder structure.

If the highest-impact optimization requires crossing that line: **stop, do not apply it**, and draft `ARCHITECTURE_CHANGE_REQUEST.md` (reason, impact, affected modules, migration plan, risks, alternatives) for the owner to approve — per the charter.

## 5. Apply incrementally, verify each step

For each optimization, one at a time:
1. Apply the change.
2. Run the test suite — any failure means fix or revert before moving on.
3. Re-measure against the baseline.
4. Keep only changes with a real measured improvement (or clear, stated size/readability gains); revert neutral or regressive ones — do not leave "probably faster" code behind.

## 6. Record (MasterPlan projects only)

Append events to `state/events.jsonl` (`{"type": "Benchmark", ...}` for measurements, `{"type": "Optimize", ...}` per applied change) following the charter's stable-ID rules.

## 7. Report format

Lead with a baseline → after table for every metric touched (with units and how measured). Then: changes applied (file:line, one-line rationale each), changes attempted and reverted (with the numbers that killed them), and ideas rejected up front with reasons. If results are within noise, say "no measurable improvement" honestly.
