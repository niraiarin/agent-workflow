# Sample Agentic Workflow for Claude Code

Implementation of the Sample Agentic Workflow for Claude Code using skills.

## Installation

Choose one of the following installation options:

### Option 1: Project-Specific Skills (Recommended)

Install skills for this project only:

```bash
# From the repository root
cp -r claude-code/skills .claude/skills/
```

### Option 2: Personal Skills

Install skills for all your Claude Code projects:

```bash
# From the repository root
cp -r claude-code/skills/* ~/.claude/skills/
```

## Setup

1. Copy `CLAUDE.md` to your project root
2. Customize it with your project-specific requirements
3. Keep it under 200 lines for optimal context management

## Available Skills

### On-Demand Phases

- `/wf-investigate` - Understand code or enrich sparse issues
- `/wf-design` - Define interfaces (signatures only, no implementation)
- `/wf-adr` - Create Architecture Decision Records for significant decisions
- `/wf-issue-plan` - Define an issue with success criteria

### Core Workflow

- `/wf-01-define-gates` - Define verification gates (mandatory before task planning)
- `/wf-15-define-test-cases` - Define concrete test cases for Test-based Gates (conditional)
- `/wf-02-task-plan` - Plan tasks based on gates and complexity
- `/wf-03-implement` - Execute single task with verification
- `/wf-04-cleanup` - Three-phase audit before PR

### Meta Phases

- `/wf-summarise` - Checkpoint session for handoff
- `/wf-workflow` - Explain methodology and answer questions

## Usage

Start a new session for each task to prevent context pollution. The workflow enforces small, reviewable commits and explicit verification gates.

See [docs/agentic-workflow-guide.md](../docs/agentic-workflow-guide.md) for complete workflow documentation.
