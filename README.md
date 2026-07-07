# RWANG PROMAX

**Universal, agent-agnostic project protocols for AI-driven development.**

The **RWANG:** family is a set of drop-in prompt modules that turn any AI coding agent into a disciplined engineering organization. No SaaS, no dependencies — just Markdown files your agent reads and obeys.

Current modules:

- **RWANG:MasterPlan** — architecture-first, multi-agent project protocol (design everything through gated phases before code)
- **RWANG:Core** — standing behavior rules R1–R10 (assumptions first, simplicity, surgical changes, doc-first, RCA-first, DoD, risk classes, scope boundary, C-1/C-2/C-3 complexity workflow) — always in effect once installed
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

## Quick Start

```sh
git clone https://github.com/Freshair129/RWANG-PROMAX.git
cd RWANG-PROMAX
```

### For Claude Code — install as skills (works in every project)

```sh
./install.sh        # macOS / Linux / Git Bash
powershell -ExecutionPolicy Bypass -File install.ps1   # Windows
```

Then open any project folder and type `RWANG:MasterPlan`, `RWANG:Review`, or `RWANG:Optimize`. The MasterPlan skill drops the needed files into the project on first use and auto-resumes from saved phase state next session — type anything ("continue", "ทำต่อ") and it picks up where it left off.

### For Codex, Cursor, Cline, Aider, local LLMs — drop files into your project

```sh
./rwang-init.sh /path/to/your/project        # macOS / Linux / Git Bash
.\rwang-init.ps1 C:\path\to\your\project      # Windows
```

This copies the three module files plus `AGENTS.md` (read automatically by Codex/Cursor/etc.) and `CLAUDE.md` into your project. Then just tell your agent **`RWANG:MasterPlan`** — it reads `AGENTS.md`, learns the command dispatch table, and starts. `RWANG:Review` and `RWANG:Optimize` work the same way.

No script? Copy these into your project root by hand and tell the agent to read `AGENTS.md`:

```
RWANG-MASTERPLAN.md  RWANG-REVIEW.md  RWANG-OPTIMIZE.md
AGENTS.md   (from templates/)
```

## How it works

```
your-project/
├─ RWANG-MASTERPLAN.md          ← the MasterPlan (rules of engagement)
├─ RWANG-CORE.md                ← standing rules R1–R10 (always in effect)
├─ RWANG-REVIEW.md              ← RWANG:Review module
├─ RWANG-OPTIMIZE.md            ← RWANG:Optimize module
├─ RWANG-VERSION.md             ← RWANG:Version module
├─ .rwang/                      ← version sidecar: registry.json + meta/<path>.json (changelogs)
├─ AGENTS.md                    ← command dispatch table (Codex/Cursor/others auto-load this)
├─ CLAUDE.md                    ← same dispatch for Claude Code
├─ README.md                    ← reserved for humans (never touched)
├─ project/                     ← YOUR input: specs, ideas, notes (read-only for agents)
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
| `RWANG:MasterPlan` | `rwang-masterplan` | Architect — designs everything, writes no production code |
| `RWANG:Core` | `rwang-core` | Constitution — standing rules R1–R10, always in effect once present |
| `RWANG:Review` | `rwang-review` | Reviewer — reports findings, changes nothing, never redesigns |
| `RWANG:Optimize` | `rwang-optimize` | Implementation — optimizes internals, never touches architecture or public APIs |
| `RWANG:Version` | `rwang-version` | Registrar — sidecar SemVer registry (originals untouched); sha256 drift audit + commit write gate |
| `RWANG:<Module>` (future) | `rwang-<module>` | — |

(Colons can't appear in Windows filenames or skill names, so disk names use hyphens.)

**How each agent finds the commands:** Claude Code discovers the installed skills by name; Codex, Cursor, Cline, Aider and others read `AGENTS.md`, which maps every `RWANG:` command to the file to open. Either way, typing `RWANG:Review` makes the agent read `RWANG-REVIEW.md` and follow it. The module files are plain Markdown with no tool-specific assumptions.

---

## 🇹🇭 ภาษาไทย

**RWANG:MasterPlan** คือโปรโตคอลสากลแบบวางไฟล์เดียวใช้ได้ทุกโปรเจกต์: บอก agent ว่า "อ่าน MasterPlan" แล้วมันจะสำรวจ repo หาสเปกของคุณใน `project/` เช็คสถานะจาก `state/PROJECT_STATE.json` แล้วทำงานต่อจากจุดเดิมเองทันที — ออกแบบสถาปัตยกรรมครบ 7 phase ก่อนเขียนโค้ด หยุดรอคุณอนุมัติทุกด่าน (พิมพ์ "อนุมัติ" เพื่อไปต่อ) และแตกงานเป็น task ให้ agent หลายตัว (รวมถึง local LLM) ทำขนานกันได้โดยไม่ตีกัน

**Claude Code:** รัน `install.ps1` (Windows) หรือ `install.sh` — ติดตั้งเป็น skill ใช้ได้ทุกโปรเจกต์ พิมพ์ `RWANG:MasterPlan` ได้เลย
**Codex / Cursor / Cline / Aider / local LLM:** รัน `rwang-init.ps1 C:\path\to\project` (หรือ `rwang-init.sh`) เพื่อวางไฟล์ RWANG ลงในโปรเจกต์ — agent จะอ่าน `AGENTS.md` เห็นตารางคำสั่งแล้วทำงานตาม `RWANG:MasterPlan` / `RWANG:Review` / `RWANG:Optimize` ได้ทันที

โมดูลเสริม (ติดตั้งมาพร้อมกัน): `RWANG:Core` กฎพฤติกรรม R1–R10 ที่บังคับใช้ตลอดเวลา (แถลง assumption ก่อนทำ, แก้เท่าที่ขอ, doc-first รออนุมัติ, หา root cause ก่อนแก้บั๊ก, จัดระดับความซับซ้อน C-1/2/3), `RWANG:Review` รีวิวโค้ดหลายมิติแบบรายงานอย่างเดียวไม่แก้เอง, `RWANG:Optimize` ปรับ performance แบบวัดผลก่อน-หลัง อะไรที่วัดแล้วไม่ดีขึ้นจะ revert ทิ้ง — ทั้งคู่เคารพกฎ RWANG: ห้ามแตะสถาปัตยกรรมและ public API — และ `RWANG:Version` ระบบ version x.y.z ของทุกเอกสาร/โค้ดแบบ**ไม่แตะไฟล์ต้นฉบับ** — metadata + changelog อยู่ใน sidecar `.rwang/` ที่ mirror ชื่อไฟล์เดิม, audit จับ drift ด้วย sha256 (แก้ไฟล์แต่ไม่ bump = โดนจับ), มี git pre-commit **write gate** ปฏิเสธ commit ที่แก้ไฟล์ลงทะเบียนโดยไม่ผ่าน bump: เอกสาร draft = 0.x, phase อนุมัติแล้ว = 1.0.0 (frozen), จะ bump MAJOR หลัง freeze ต้องมี change request ก่อน

## License

[MIT](./LICENSE)
