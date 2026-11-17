# tadashi skills

The primary skill kit every Claude session on this machine loads, laid out the way pstack is: one folder per skill under `skills/`, each with a `SKILL.md` and, when it needs them, `references/` (read on demand), `scripts/` (run as written) and `assets/` (files copied into a project). pstack sits on top as the working style; these skills are the house knowledge it reaches for.

`setup\deploy.ps1` mirrors `skills/` into `~/.claude/skills`, and `CLAUDE.md` into `~/.claude/CLAUDE.md`.

## Primary

The ones that define how work looks here. Reach for these first.

| Skill | What it owns |
|:--|:--|
| [models](skills/models/SKILL.md) | Opus 5.5 low for the lead, Sonnet for every subagent |
| [onestyle](skills/onestyle/SKILL.md) | The house look, flows, voice and stack for every product |
| [finish](skills/finish/SKILL.md) | Ghost effects from Helios and the 3D lanyard about page from Bespoke |
| [folio](skills/folio/SKILL.md) | Every PDF, including lab records in the Amrita style |
| [explain](skills/explain/SKILL.md) | Softened STE prose, diagrams, HTML explainers, narrated videos |
| [vibe](skills/vibe/SKILL.md) | The default writing voice |
| [voice](skills/voice/SKILL.md) | The formal writing voice |
| [authorship](skills/authorship/SKILL.md) | Sole authorship, plain Karpathy-style commits and comments |
| [genesis](skills/genesis/SKILL.md) | Every new project, set up and passing before the first feature |

## Design and build

| Skill | What it owns |
|:--|:--|
| [atelier](skills/atelier/SKILL.md) | Award-level frontends |
| [essentials](skills/essentials/SKILL.md) | What every site must ship before it is done |
| [anatomy](skills/anatomy/SKILL.md) | Interactive isometric SVG figures |
| [impeccable](skills/impeccable/SKILL.md) | Design critique and polish, on request only |
| [ui-refine-loop](skills/ui-refine-loop/SKILL.md) | Unattended check and fix loop on one page |
| [visual](skills/visual/SKILL.md) | One HTML page that recaps a branch, plan or system |
| [build-mcp-server](skills/build-mcp-server/SKILL.md) | MCP servers and integrations |

## Engineering discipline

| Skill | What it owns |
|:--|:--|
| [karpathy-guidelines](skills/karpathy-guidelines/SKILL.md) | Surgical, simple, verifiable changes |
| [test-driven-development](skills/test-driven-development/SKILL.md) | Tests before non-trivial logic |
| [diagnosing-bugs](skills/diagnosing-bugs/SKILL.md) | The loop for hard bugs and regressions |
| [verification-before-completion](skills/verification-before-completion/SKILL.md) | Evidence before any claim of done |
| [receiving-code-review](skills/receiving-code-review/SKILL.md) | Weighing review feedback with rigour |
| [planning-and-task-breakdown](skills/planning-and-task-breakdown/SKILL.md) | Large work into ordered, checkable tasks |
| [grilling](skills/grilling/SKILL.md) | Stress-testing a plan |

## Git and pipelines

| Skill | What it owns |
|:--|:--|
| [git-sync](skills/git-sync/SKILL.md) | Commit, pull and push in one pass |
| [using-git-worktrees](skills/using-git-worktrees/SKILL.md) | Isolated feature work |
| [finishing-a-development-branch](skills/finishing-a-development-branch/SKILL.md) | Integrating finished work |
| [dispatching-parallel-agents](skills/dispatching-parallel-agents/SKILL.md) | Independent tasks in parallel |
| [super-board](skills/super-board/SKILL.md) | GitHub Project board drained by an autonomous pipeline |
| [super-collect](skills/super-collect/SKILL.md) | Finding and filing problems onto the board |

## Research

| Skill | What it owns |
|:--|:--|
| [osint](skills/osint/SKILL.md) | Passive-first public-source investigation |

Engineered by [Ritesh Roshan](https://github.com/riteshroshann).
