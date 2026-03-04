# Sample Agentic Workflow for Gemini CLI

Implementation of the Sample Agentic Workflow for Gemini CLI using TOML commands.

## Installation

Copy the commands to your Gemini commands directory:

```bash
cp commands/*.toml ~/.gemini/commands/
```

## Setup

1. Copy `GEMINI.md` to your project root
2. Customize it with your project-specific requirements
3. Keep it under 200 lines for optimal context management

## Available Commands

### On-Demand Phases

- `wf-investigate` - Understand code or enrich sparse issues
- `wf-design` - Define interfaces (signatures only, no implementation)
- `wf-adr` - Create Architecture Decision Records for significant decisions
- `wf-issue-plan` - Define an issue with success criteria

### Core Workflow

- `wf-01-define-gates` - Define verification gates (mandatory before task planning)
- `wf-02-task-plan` - Plan tasks based on gates and complexity
- `wf-03-implement` - Execute single task with verification
- `wf-04-cleanup` - Three-phase audit before PR

### Meta Phases

- `wf-summarise` - Checkpoint session for handoff
- `wf-workflow` - Explain methodology and answer questions

## Usage

Start a new session for each task to prevent context pollution. The workflow enforces small, reviewable commits and explicit verification gates.

See [docs/agentic-workflow-guide.md](docs/agentic-workflow-guide.md) for complete workflow documentation.
