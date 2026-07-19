# RWANG Agent Working Agreement

This project uses three RWANG skills under `.agents/skills/`:

- `rwang` - init, scan, plan, continue, status, and version governance
- `rwang-review` - read-only engineering review
- `rwang-optimize` - measured implementation optimization

Read `.agents/skills/rwang/SKILL.md` and its required references before any RWANG planning action. The human owner is the only approval authority. New planned feature/architecture code begins only after DG0-DG6 are approved; narrowly bounded LOW-risk C-1 maintenance on an existing brownfield codebase follows the exception in `references/CORE.md`. Existing `docs/PHASE_<N>_REVIEW.md` files are migration history and must be preserved.

## Command routing

| User says | Route |
|---|---|
| `RWANG:init` | `.agents/skills/rwang/SKILL.md` -> init |
| `RWANG:scan [--deep]` | `.agents/skills/rwang/SKILL.md` -> scan |
| `RWANG:plan` | `.agents/skills/rwang/SKILL.md` -> plan |
| `RWANG:continue` | `.agents/skills/rwang/SKILL.md` -> continue |
| `RWANG:status` | `.agents/skills/rwang/SKILL.md` -> status |
| `RWANG:version ...` | `.agents/skills/rwang/SKILL.md` -> version |
| `RWANG:Review` | `.agents/skills/rwang-review/SKILL.md` |
| `RWANG:Optimize` | `.agents/skills/rwang-optimize/SKILL.md` |

Plain-text legacy commands `RWANG:QuickStart`, `RWANG:MasterPlan`, `RWANG:Core`, and `RWANG:Version` route through `rwang` and emit a deprecation note. Explicit retired selectors such as `$rwang-quickstart` cannot resolve in 2.0; use `$rwang` with the canonical command.

Never copy RWANG module payloads into the project root. Never overwrite an existing Git hook; merge the governed-artifact gate manually. Never use `--no-verify`.
