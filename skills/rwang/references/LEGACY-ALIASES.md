# Legacy Alias Migration

Legacy aliases remain routed by the `rwang` skill during the 2.x migration window; they are not separate installed skills.

| Legacy invocation | Canonical route | Note |
|---|---|---|
| `RWANG:QuickStart`, `quick start` | `RWANG:init` | Same onboarding intent plus mandatory reality evidence. |
| `RWANG:MasterPlan` | `RWANG:plan` or `RWANG:continue` | Select by existing state. |
| `RWANG:Core` | load Core policy | Core is automatic. |
| `RWANG:Version` | `RWANG:version` | Audit remains the default action. |

Emit: `Legacy alias <name> routed to <canonical>; migrate when convenient.` Do not create compatibility copies of the retired skill folders because that restores duplicate SSOTs and expands the user-facing skill count.

## Explicit skill selectors

`$rwang-quickstart`, `$rwang-masterplan`, `$rwang-core`, and `$rwang-version` are **breaking removals in 2.0**: a harness resolves these selectors by installed folder name, so the umbrella skill cannot intercept them. Use `$rwang` and include `RWANG:init`, `RWANG:plan`, `RWANG:continue`, or `RWANG:version` in the request. Plain-text legacy commands above remain routable.
