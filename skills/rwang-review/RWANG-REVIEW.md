# RWANG Review Policy

Review is read-only and never redesigns architecture.

1. Resolve the target from an explicit argument, uncommitted diff, latest Execution wave, or current Design Gate. Ask only if none exists.
2. Run existing deterministic checks first: build/typecheck, tests, lint, schema validation, and relevant smoke checks.
3. Review correctness, security, edge cases, performance, maintainability/readability, then alignment with approved Design Gates.
4. Substantiate each finding with a concrete failure scenario and tight `file:line` evidence. Rank Critical, Major, Minor, or Nit. Drop speculative findings.
5. Report only. Architectural fixes require an Architecture Change Request; do not draft a redesign inline.
6. In RWANG projects, record the report at `docs/reviews/REVIEW-<target>-<n>.md` and append a review event. The owner controls approval and queue status.

Lead with pass, pass-with-issues, or fail. End with deterministic check results. Do not pad a clean review.
