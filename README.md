# RWANG PROMAX

**Universal, agent-agnostic project protocols for AI-driven development.**

The **RWANG:** family is a set of drop-in prompt modules that turn any AI coding agent into a disciplined engineering organization. No SaaS, no dependencies — just Markdown files your agent reads and obeys.

Current modules:

- **RWANG:MasterPlan** — architecture-first, multi-agent project protocol (design everything through gated phases before code)
- **RWANG:Review** — multi-dimensional engineering review that never redesigns architecture
- **RWANG:Optimize** — measured, architecture-preserving optimization (baseline → change → re-measure)

> ภาษาไทยอยู่ด้านล่าง 🇹🇭

---

## What is RWANG:MasterPlan?

Drop one file into any project folder. Tell your agent to read it. The agent then:

1. **Bootstraps itself** — inventories the repo, finds your project materials, resolves where work left off from a state file
2. **Acts as a Principal Systems Architect** — designs the entire system through 7 gated phases (Discovery → Architecture → Contracts → Multi-Agent Design → Specs → QA → Handoff) before any production code is written
3. **Decomposes work for a fleet of agents** — cloud or local LLMs, routed by capability scores, never by model name
4. **Stops at approval gates** — you (the human owner) are the only approval authority; approved phases are architecturally frozen
5. **Implements wave by wave** — from a machine-readable `IMPLEMENTATION_QUEUE.json`, with deterministic verification (compilers and tests, never LLM-as-judge)

Works with Claude Code, Codex, Cursor, local LLMs — anything that can read a Markdown file and follow instructions.

## Quick Start

### Option A — Claude Code skill (recommended)

Installs once, works in every project on your machine:

```sh
git clone https://github.com/Freshair129/RWANG-PROMAX.git
cd RWANG-PROMAX
./install.sh        # macOS / Linux / Git Bash
# or
powershell -ExecutionPolicy Bypass -File install.ps1   # Windows
```

Then open any project folder in Claude Code and type:

```
RWANG:MasterPlan
```

The skill installs `RWANG-MASTERPLAN.md` into the project (if missing), creates `CLAUDE.md` / `AGENTS.md` pointers, and starts the Bootstrap Protocol. Next sessions auto-resume from the saved phase state — type anything ("continue", "ทำต่อ") and it picks up where it left off.

The installer installs the whole family, so you can also type `RWANG:Review` (review a diff, task, wave, or phase — report only, ranked by severity) and `RWANG:Optimize` (optimize with before/after measurements, reverting anything that doesn't provably improve).

### Option B — Any agent, no install

Copy three files into your project root:

```
RWANG-MASTERPLAN.md      ← the MasterPlan
templates/CLAUDE.md      ← pointer for Claude Code (auto-loaded)
templates/AGENTS.md      ← pointer for Codex / Cursor / others
```

Then tell your agent: **"Read RWANG-MASTERPLAN.md and execute its Bootstrap Protocol."**

## How it works

```
your-project/
├─ RWANG-MASTERPLAN.md          ← the MasterPlan (rules of engagement)
├─ CLAUDE.md / AGENTS.md        ← one-line pointers, auto-loaded by agents
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
| `RWANG:Review` | `rwang-review` | Reviewer — reports findings, changes nothing, never redesigns |
| `RWANG:Optimize` | `rwang-optimize` | Implementation — optimizes internals, never touches architecture or public APIs |
| `RWANG:<Module>` (future) | `rwang-<module>` | — |

(Colons can't appear in Windows filenames or skill names, so disk names use hyphens.)

---

## 🇹🇭 ภาษาไทย

**RWANG:MasterPlan** คือโปรโตคอลสากลแบบวางไฟล์เดียวใช้ได้ทุกโปรเจกต์: บอก agent ว่า "อ่าน MasterPlan" แล้วมันจะสำรวจ repo หาสเปกของคุณใน `project/` เช็คสถานะจาก `state/PROJECT_STATE.json` แล้วทำงานต่อจากจุดเดิมเองทันที — ออกแบบสถาปัตยกรรมครบ 7 phase ก่อนเขียนโค้ด หยุดรอคุณอนุมัติทุกด่าน (พิมพ์ "อนุมัติ" เพื่อไปต่อ) และแตกงานเป็น task ให้ agent หลายตัว (รวมถึง local LLM) ทำขนานกันได้โดยไม่ตีกัน

**ติดตั้งแบบ Claude Code skill:** รัน `install.ps1` (Windows) หรือ `install.sh` แล้วพิมพ์ `RWANG:MasterPlan` ในโปรเจกต์ไหนก็ได้
**ใช้กับ agent อื่น:** ก๊อป `RWANG-MASTERPLAN.md` + ไฟล์ใน `templates/` ไปวางที่ root ของโปรเจกต์

โมดูลเสริม (ติดตั้งมาพร้อมกัน): `RWANG:Review` รีวิวโค้ดหลายมิติแบบรายงานอย่างเดียวไม่แก้เอง และ `RWANG:Optimize` ปรับ performance แบบวัดผลก่อน-หลัง อะไรที่วัดแล้วไม่ดีขึ้นจะ revert ทิ้ง — ทั้งคู่เคารพกฎ RWANG: ห้ามแตะสถาปัตยกรรมและ public API

## License

[MIT](./LICENSE)
