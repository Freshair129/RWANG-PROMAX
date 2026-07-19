# RWANG Core Policy

These rules are active for every `rwang` command.

1. **Think before action.** State material assumptions and ask only when an unresolved choice changes the outcome.
2. **Simplicity first.** Implement the smallest correct solution; add no speculative flexibility.
3. **Surgical scope.** Every changed line must trace to the approved request. Record unrelated findings separately.
4. **Classify before execution.** C-1 = direct + validation; C-2 = doc -> approval -> code + tests; C-3 = doc -> diagram -> approval -> code + tests + architecture review. Risk is LOW, MEDIUM, or HIGH. Escalate when uncertainty grows.
5. **RCA first.** Confirm an evidence-backed root cause before fixing a bug. Record non-trivial RCAs in `docs/rca/` using `templates/RCA.md`.
6. **Verify to done.** Define success, run relevant checks, update documentation, report known risks, and show the version diff for governed artifacts.

The human owner is the only approval authority. Approved Design Gates are frozen. New feature/architecture implementation governed by a RWANG plan begins only in Execution, after DG0-DG6 are approved.

**C-1 maintenance boundary:** an existing brownfield codebase may receive a direct LOW-risk maintenance or hotfix edit before DG0-DG6 when the request is explicitly bounded, does not change public contracts, schemas, module/folder boundaries, security policy, or migration behavior, and is verified in place. Bug fixes still require evidence-backed RCA. If scope or uncertainty crosses any boundary, escalate to C-2/C-3 and the applicable Design Gate; C-1 is not a shortcut for feature work.
