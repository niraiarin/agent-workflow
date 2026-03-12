# Agent Workflow Framework

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Source](https://img.shields.io/badge/source-daniel--butler--irl-green.svg)](https://github.com/daniel-butler-irl/sample-agentic-workflows)

AIコーディングエージェント（Claude、Bob、Gemini、Grok、vibe-local等）と協働するための構造化されたワークフローフレームワーク。

A structured workflow framework for collaborating with AI coding agents (Claude, Bob, Gemini, Grok, vibe-local, etc.).

---

## Supported Agents

| Agent | Format | Features |
|-------|--------|----------|
| **Bob** | Markdown Commands | VS Code extension, command-based |
| **Claude Code** | Skills | Official Claude, skill system |
| **Codex CLI** | Skills | OpenAI Codex, skill system |
| **Gemini CLI** | TOML Commands | Google Gemini, TOML commands |
| **Grok CLI** | TOML Commands | xAI Grok, TOML commands |
| **vibe-local** | Markdown Skills | Local LLM, 2000-char limit |

Each agent directory contains setup instructions and usage guidelines.

---

## Quick Start

### 1. Set up agent-specific files

**Bob:**
```bash
cp -r agent-workflow/bob/commands .bob/commands/
cp agent-workflow/bob/AGENTS.md ./AGENTS.md
```

**Claude Code:**
```bash
cp -r agent-workflow/claude-code/skills .claude/skills/
cp agent-workflow/claude-code/CLAUDE.md ./CLAUDE.md
```

**vibe-local:**
```bash
mkdir -p .vibe-local/skills
cp agent-workflow/vibe-local/skills/*.md .vibe-local/skills/
cp agent-workflow/vibe-local/CLAUDE.md ./CLAUDE.md
```

### 2. Customize project-specific rules

Edit `AGENTS.md` or `CLAUDE.md` to add project-specific requirements (keep under 200 lines).

### 3. Run the workflow

```bash
/wf-01-define-gates <issue-identifier>       # 1. Define verification gates
/wf-15-define-test-cases <issue-identifier>   # 2. Define test cases (if needed)
/wf-02-task-plan <issue-identifier>           # 3. Plan tasks
/wf-03-implement <issue-identifier> <task>    # 4. Implement
/wf-04-cleanup <issue-identifier>             # 5. Cleanup & PR
```

---

## Workflow Structure

```
Phase 1: Define Gates ──→ Phase 1.5: Test Cases (conditional)
         ↓
Phase 2: Task Plan ──→ Phase 3: Implement ──→ Phase 4: Next or Cleanup
         ↑                                              ↓
         └──────── (more gates remain) ─────────────────┘
                                                        ↓
                                              Phase 5: Cleanup → PR
```

Optional: `/wf-issue-plan`, `/wf-investigate`, `/wf-design`, `/wf-adr`, `/wf-summarise`, `/wf-workflow`

---

## Documentation

| Document | Description |
|----------|-------------|
| **[docs/index.md](docs/index.md)** | Documentation hub (Diataxis navigation) |
| **[docs/agentic-workflow-guide.md](docs/agentic-workflow-guide.md)** | Complete workflow guide — phases, anti-patterns, optimization |
| **[docs/explanation/manifesto.md](docs/explanation/manifesto.md)** | Project manifesto — perpetual self-optimization by AI |
| **[docs/explanation/principles.md](docs/explanation/principles.md)** | Core philosophy and design principles |
| **[docs/explanation/doc-generation-architecture.md](docs/explanation/doc-generation-architecture.md)** | Documentation generation architecture and maintenance |
| **[docs/reference/commands.md](docs/reference/commands.md)** | Command reference |
| **[docs/how-to/phases.md](docs/how-to/phases.md)** | Phase-by-phase how-to guide |

### Agent-Specific Documentation

- [bob/README.md](bob/README.md) | [claude-code/README.md](claude-code/README.md) | [codex-cli/README.md](codex-cli/README.md)
- [gemini-cli/README.md](gemini-cli/README.md) | [grok-cli/README.md](grok-cli/README.md) | [vibe-local/README.md](vibe-local/README.md)

---

## Directory Structure

```
agent-workflow/
├── docs/                        # Single Source of Truth (manual editing)
│   ├── agentic-workflow-guide.md  # Main guide
│   ├── explanation/               # Why/how (design, architecture)
│   ├── how-to/                    # Phase guides
│   └── reference/                 # Command reference
├── bob/                         # Bob implementation (AI-generated)
├── claude-code/                 # Claude Code implementation (AI-generated)
├── codex-cli/                   # Codex CLI implementation (AI-generated)
├── gemini-cli/                  # Gemini CLI implementation (AI-generated)
├── grok-cli/                    # Grok CLI implementation (AI-generated)
└── vibe-local/                  # vibe-local implementation (AI-generated)
```

**Important:** `docs/` = Single Source of Truth (manual editing). Agent directories = AI-generated files (do not edit directly). See [doc-generation-architecture.md](docs/explanation/doc-generation-architecture.md) for details.

---

## Contributing

Agent-specific files (bob/commands/, claude-code/skills/, etc.) are AI-generated. Do not edit them directly.

**Contribution process:**
1. Edit `docs/agentic-workflow-guide.md` (the source of truth)
2. Commit docs/ changes
3. Regenerate agent files — see [Maintenance Guidelines](docs/explanation/doc-generation-architecture.md#maintenance-guidelines)
4. Create Pull Request with both docs/ and regenerated files

---

## License

This project is licensed under the MIT License.

## Acknowledgments

Original repository: https://github.com/daniel-butler-irl/sample-agentic-workflows by Daniel Butler
