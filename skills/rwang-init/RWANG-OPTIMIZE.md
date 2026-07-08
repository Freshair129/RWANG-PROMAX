# RWANG:Optimize — Measured Optimization Module

> Part of the **RWANG:** family. Tool-neutral: any agent (Claude, Codex, Cursor, local LLM) executes this by reading the file.
> **Trigger:** the user says **"RWANG:Optimize"** (optionally with a target: a path, module, or metric like "startup time", "bundle"). When triggered, follow this module exactly.

Optimizes **implementation, never architecture** — the Implementation-agent boundary from RWANG:MasterPlan. Every change must be justified by a measurement.

## 1. Resolve the target

1. Explicit argument (path, module, or metric).
2. Otherwise: the project's hot path — ask one question only if the goal is genuinely undecidable (speed vs memory vs size lead to different work).

## 2. Measure first — never optimize blind

- Run existing benchmarks/perf tests if the project has them.
- Otherwise establish a quick baseline appropriate to the goal: timed runs, bundle-size report, memory snapshot, query counts, profiler output.
- Record the baseline numbers. If nothing measurable can be established, say so and downgrade to a static review of algorithmic complexity — clearly labeled as unmeasured.

## 3. Identify and rank candidates

Profile or inspect to find hotspots. Rank by expected impact ÷ effort. Typical wins: algorithmic complexity, N+1 I/O, caching/memoization, unnecessary re-renders/allocations, lazy loading, dead code and duplicate logic, over-general abstractions used once (simplification counts as optimization).

## 4. Hard constraints (RWANG role boundaries)

MAY: optimize implementation, improve performance, improve typing, add/adjust tests, simplify private internals.
MUST NOT: redesign architecture, rename public APIs, merge modules, remove abstraction layers, change communication protocols, change folder structure.

If the highest-impact optimization requires crossing that line: **stop, do not apply it**, and draft `ARCHITECTURE_CHANGE_REQUEST.md` (reason, impact, affected modules, migration plan, risks, alternatives) for the owner to approve — per RWANG rules.

## 5. Apply incrementally, verify each step

For each optimization, one at a time:
1. Apply the change.
2. Run the test suite — any failure means fix or revert before moving on.
3. Re-measure against the baseline.
4. Keep only changes with a real measured improvement (or clear, stated size/readability gains); revert neutral or regressive ones — do not leave "probably faster" code behind.

## 6. Record (RWANG projects only)

Append events to `state/events.jsonl` (`{"type": "Benchmark", ...}` for measurements, `{"type": "Optimize", ...}` per applied change) following the RWANG stable-ID rules.

## 7. Report format

Lead with a baseline → after table for every metric touched (with units and how measured). Then: changes applied (file:line, one-line rationale each), changes attempted and reverted (with the numbers that killed them), and ideas rejected up front with reasons. If results are within noise, say "no measurable improvement" honestly.
