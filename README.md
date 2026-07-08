# RWANG PROMAX

**Universal, agent-agnostic project protocols for AI-driven development.**

The **RWANG:** family is a set of drop-in prompt modules that turn any AI coding agent into a disciplined engineering organization. No SaaS, no dependencies — just Markdown files your agent reads and obeys.

Current modules:

- **RWANG:QuickStart** — one command from zero to ready: runs Core → Version → MasterPlan in order (rules loaded, registry + write gate armed, bootstrapped to the first approval gate)
- **RWANG:MasterPlan** — architecture-first, multi-agent project protocol (design everything through gated phases before code)
- **RWANG:Core** — six standing behavior rules, always in effect once installed: assumptions first, simplicity, surgical & scoped changes, C-1/C-2/C-3 classification (light tasks stay light — doc-first only from C-2 up), RCA-first, verify to done
- **RWANG:Review** — multi-dimensional engineering review that never redesigns architecture
- **RWANG:Optimize** — measured, architecture-preserving optimization (baseline → change → re-measure)
- **RWANG:Version** — SemVer (x.y.z) for every doc and code artifact via a non-invasive `.rwang/` sidecar registry (originals never touched), with sha256 drift audit and a git pre-commit write gate

> ภาษาไทยอยู่ด้านล่าง 🇹🇭

---

## What is RWANG:MasterPlan?

Drop one file into any project folder. Tell your agent to read it. The agent then:

1. **Bootstraps itself** — inventories the repo, finds your project materials, resolves where work left off from a state file
2. **Acts as a Principal Systems Architect** — designs the entire system through 7 gated phases (Discovery → Architecture → Contracts → Multi-Agent Design → Specs → QA → Handoff) before any production code is written
3. **Decomposes work for a fleet of agents** — cloud or local LLMs, routed by capability scores, never by model name
4. **Stops at approval gates** — you (the human owner) are the only approval authority; approved phases are architecturally frozen
5. **Implements wave by wave** — from a machine-readable `IMPLEMENTATION_QUEUE.json`, with deterministic verification (compilers and tests, never LLM-as-judge)

Works with **Claude Code, Codex, Cursor, Cline, Aider, and local LLMs** — anything that can read a Markdown file and follow instructions. RWANG is just files; there is no runtime to install.

## Quick Start — one command, done

```powershell
# Windows
iwr -useb https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.ps1 | iex
```
```sh
# macOS / Linux / Git Bash
curl -fsSL https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.sh | sh
```

This puts the toolkit at **`~/.rwang`** and installs the skills to **one single source of truth: `~/.agents/skills`** (the cross-tool standard). Claude Code and Antigravity read the same files through symlinks/junctions — one copy, every harness, updates land everywhere at once. There is **no step 2**: open any project and type **`RWANG:QuickStart`** — it loads the Core rules, arms the version registry + write gate, and bootstraps the MasterPlan to the first approval gate. **Your project stays clean**: no RWANG command files are copied into it — only its own artifacts (`docs/ state/ queue/ src/ .rwang/`).

| Harness | Reads skills from | Invoke |
|---|---|---|
| Codex CLI | `~/.agents/skills/` (SSOT) | `$rwang-quickstart` — or just type `RWANG:QuickStart` (implicit match) |
| Claude Code | `~/.claude/skills/` → symlink → SSOT | type `RWANG:QuickStart` or `/rwang-quickstart` |
| Antigravity CLI | `~/.gemini/antigravity-cli/skills/` → symlink → SSOT | `/skills` picker — or type `RWANG:QuickStart` |

Your spec/idea files can live **at the project root** (or in an optional `project/` folder if you have many) — the Bootstrap Protocol reads them as Phase 0 input either way. Each skill also ships a `templates/` folder with the document skeletons it produces (MASTER_PLAN, PHASE_REVIEW, ARCHITECTURE_CHANGE_REQUEST, RCA, REVIEW, registry/meta examples).

### Agents without a skill system (Cursor, Cline, Aider, local LLMs)

```sh
~/.rwang/rwang-init.sh /path/to/your/project          # macOS / Linux / Git Bash
powershell -File $HOME\.rwang\rwang-init.ps1 C:\path\to\project   # Windows
```

This copies into the project: the five module files, `AGENTS.md` (the command dispatch table those agents auto-read), `CLAUDE.md`, workspace `.agents/skills/`, and the pre-commit write gate if the project is a git repo.

No script? Copy `RWANG-*.md` + `templates/AGENTS.md` into the project root by hand and tell the agent to read `AGENTS.md`.

## How it works

```
your-project/
├─ RWANG-MASTERPLAN.md          ← the MasterPlan (rules of engagement)
├─ RWANG-CORE.md                ← standing rules R1–R6 (always in effect)
├─ RWANG-REVIEW.md              ← RWANG:Review module
├─ RWANG-OPTIMIZE.md            ← RWANG:Optimize module
├─ RWANG-VERSION.md             ← RWANG:Version module
├─ .rwang/                      ← version sidecar: registry.json + meta/<path>.json (changelogs)
├─ AGENTS.md                    ← command dispatch table (Codex/Cursor/others auto-load this)
├─ CLAUDE.md                    ← same dispatch for Claude Code
├─ README.md                    ← reserved for humans (never touched)
├─ <your spec files>            ← YOUR input lives at the root (read-only for agents)
├─ project/                     ← optional tidiness folder for many input files
├─ docs/                        ← generated deliverables (Markdown, for humans)
├─ state/PROJECT_STATE.json     ← phase position (how sessions resume)
├─ state/*.jsonl                ← append-only runtime history
├─ queue/*.json                 ← machine-readable task queue & project graph
└─ src/                         ← implementation (only after specs are approved)
```

| Phase | Deliverable | Gate |
|---|---|---|
| 0 Discovery | Master plan, scope, glossary, requirements | Owner approves |
| 1 Architecture | System architecture, invariants, module map | Owner approves → frozen |
| 2 Contracts | Interfaces, data models, state machines | Owner approves → frozen |
| 3 Multi-Agent | Agent contracts, capability routing, dispatch | Owner approves → frozen |
| 4 Specs | Module specs, algorithms, storage | Owner approves → frozen |
| 5 QA | Test / benchmark / verification strategy | Owner approves |
| 6 Handoff | Task breakdown + `IMPLEMENTATION_QUEUE.json` | Owner approves |
| 7 Implementation | Code, wave by wave, verified deterministically | Per-wave review |

Full rules are in [RWANG-MASTERPLAN.md](./RWANG-MASTERPLAN.md) — it is self-contained.

## The RWANG: family

| In conversation | Skill name | Role (per RWANG:MasterPlan) |
|---|---|---|
| `RWANG:QuickStart` | `rwang-quickstart` | Onboarder — composes Core + Version + MasterPlan in one shot; never implements |
| `RWANG:MasterPlan` | `rwang-masterplan` | Architect — designs everything, writes no production code |
| `RWANG:Core` | `rwang-core` | Constitution — six standing rules, always in effect once present; ceremony scales C-1→C-3 |
| `RWANG:Review` | `rwang-review` | Reviewer — reports findings, changes nothing, never redesigns |
| `RWANG:Optimize` | `rwang-optimize` | Implementation — optimizes internals, never touches architecture or public APIs |
| `RWANG:Version` | `rwang-version` | Registrar — sidecar SemVer registry (originals untouched); sha256 drift audit + commit write gate |
| `RWANG:<Module>` (future) | `rwang-<module>` | — |

(Colons can't appear in Windows filenames or skill names, so disk names use hyphens.)

**How each agent finds the commands:** Claude Code, Codex, and Antigravity discover the installed skills (same `SKILL.md` format everywhere — machine-level or workspace `.agents/skills/`); every agent additionally gets `AGENTS.md`, which maps each `RWANG:` command to the file to open — that covers Cursor, Cline, Aider, and local LLMs with no skill system. Either way, typing `RWANG:Review` makes the agent read `RWANG-REVIEW.md` and follow it. The module files are plain Markdown with no tool-specific assumptions.

---

## 🇹🇭 ภาษาไทย

**RWANG:MasterPlan** คือโปรโตคอลสากลแบบวางไฟล์เดียวใช้ได้ทุกโปรเจกต์: บอก agent ว่า "อ่าน MasterPlan" แล้วมันจะสำรวจ repo หาสเปกของคุณใน `project/` เช็คสถานะจาก `state/PROJECT_STATE.json` แล้วทำงานต่อจากจุดเดิมเองทันที — ออกแบบสถาปัตยกรรมครบ 7 phase ก่อนเขียนโค้ด หยุดรอคุณอนุมัติทุกด่าน (พิมพ์ "อนุมัติ" เพื่อไปต่อ) และแตกงานเป็น task ให้ agent หลายตัว (รวมถึง local LLM) ทำขนานกันได้โดยไม่ตีกัน

**ติดตั้งคำสั่งเดียวจบ ใช้ได้สามค่าย:** `iwr -useb https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.ps1 | iex` (Windows) หรือ `curl -fsSL .../install.sh | sh` — toolkit ลงที่ `~/.rwang` และ skill ถูกลงทะเบียนให้ **Claude Code**, **Codex CLI** (`$rwang-masterplan`), **Antigravity CLI** (`/skills`) พร้อมกัน — **ไม่มี step 2**: เปิดโปรเจกต์ไหนก็ได้แล้วเรียก skill มันจะติดตั้ง RWANG ลงโปรเจกต์นั้นเอง ไฟล์สเปกวางที่ root ได้เลย (`project/` เป็นแค่ตัวเลือกจัดระเบียบ)
**Agent ที่ไม่มีระบบ skill (Cursor, Cline, Aider, local LLM):** รัน `~/.rwang/rwang-init.ps1 C:\path\to\project` — วางไฟล์โมดูล + `AGENTS.md` (ตารางคำสั่ง) ลงโปรเจกต์

เริ่มโปรเจกต์ใหม่: พิมพ์ `RWANG:QuickStart` = รัน Core → Version → MasterPlan รวดเดียว (โหลดกฎ + ตั้ง registry/write gate + bootstrap ถึง gate อนุมัติแรก) — **โปรเจกต์สะอาด ไม่มีไฟล์คำสั่งไปโผล่** เพราะ skill อ่านโมดูลจาก SSOT ที่ `~/.agents/skills` (Claude/Antigravity ใช้ผ่าน symlink)

โมดูลเสริม (ติดตั้งมาพร้อมกัน): `RWANG:Core` กฎพฤติกรรม 6 ข้อที่บังคับใช้ตลอดเวลา — แถลง assumption ก่อนทำ, เรียบง่าย, แก้เท่าที่ขอ, จัดระดับงาน C-1/2/3 (งานเบาลุยได้เลย doc-first เฉพาะ C-2 ขึ้นไป), หา root cause ก่อนแก้บั๊ก, verify ก่อนประกาศเสร็จ, `RWANG:Review` รีวิวโค้ดหลายมิติแบบรายงานอย่างเดียวไม่แก้เอง, `RWANG:Optimize` ปรับ performance แบบวัดผลก่อน-หลัง อะไรที่วัดแล้วไม่ดีขึ้นจะ revert ทิ้ง — ทั้งคู่เคารพกฎ RWANG: ห้ามแตะสถาปัตยกรรมและ public API — และ `RWANG:Version` ระบบ version x.y.z ของทุกเอกสาร/โค้ดแบบ**ไม่แตะไฟล์ต้นฉบับ** — metadata + changelog อยู่ใน sidecar `.rwang/` ที่ mirror ชื่อไฟล์เดิม, audit จับ drift ด้วย sha256 (แก้ไฟล์แต่ไม่ bump = โดนจับ), มี git pre-commit **write gate** ปฏิเสธ commit ที่แก้ไฟล์ลงทะเบียนโดยไม่ผ่าน bump: เอกสาร draft = 0.x, phase อนุมัติแล้ว = 1.0.0 (frozen), จะ bump MAJOR หลัง freeze ต้องมี change request ก่อน

## License

[MIT](./LICENSE)
