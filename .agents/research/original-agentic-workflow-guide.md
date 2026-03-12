# Research: GitHub Repo - sample-agentic-workflows/docs

**Source:** https://github.com/daniel-butler-irl/sample-agentic-workflows/tree/main/docs (files: agentic-workflow-guide-generic.md, methodology.md)

**Fetched:** 2026-03-04

## Summary
The docs directory contains \"Agentic Development Workflow Guide\" (in both agentic-workflow-guide-generic.md and methodology.md, appearing identical), a detailed methodology for effective AI agentic coding workflows. It structures development around AI limitations (amnesia, context pollution) using fresh sessions per task, verification gates, phased commands (/wf-01-define-gates, etc.), subagent research, and strict human oversight for commits and decisions.

## Key Points
- **Core Philosophy**: AI agents are like amnesiac junior devs; use fresh sessions constantly (per task, not per issue) to avoid context pollution; cost of new session (~30s) &lt; polluted context losses.
- **Design Principles**: Minimize human cognitive load (one issue/task/commit, lightweight docs); respect LLM context limits (50% rule, bounded context via structure).
- **Hierarchy**: Issues (evolving goals/success criteria), Gates (verification strategy, SIMPLE/COMPLEX assessment), Tasks (implementation steps, one commit).
- **Subagent Research**: Exactly this format (.agents/research/*.md) for external fetches/explorations; coordinator uses summary + selective deep reads.
- **Phase 0**: AGENTS.md (or CLAUDE.md) with non-negotiables (testing rules, code hygiene, no unapproved deps/changes).
- **Core Workflow**:
  | Phase | Command | Output |
  |-------|---------|--------|
  | 1 | /wf-01-define-gates &lt;issue&gt; | .agents/tasks/&lt;issue&gt;/gates.md (verification per criteria, complexity) |
  | 2 | /wf-02-task-plan &lt;issue&gt; | task-*.md (all for SIMPLE, iterative for COMPLEX) |
  | 3 | /wf-03-implement &lt;issue&gt; &lt;task&gt; | Code changes + notes; human commits |
  | 4/5 | /wf-04-cleanup &lt;issue&gt; | Audit/fix/validate all gates before PR |
- **Optional**: /wf-design, /wf-adr (architectural decisions), /wf-investigate, /wf-summarise, /wf-issue-plan.
- **Anti-Patterns**: Long sessions, skipping gates, big docs, agent commits, modifying tests to pass, unapproved deps.
- **Human Role**: Approves all changes/commits/PRs; agent proposes.
- **Recovery**: 3 failures → summarise → fresh session → manual if persists.

## Sub-Items Found
- Repo root: https://github.com/daniel-butler-irl/sample-agentic-workflows (likely contains command implementations, examples).
- No other docs files; fully covered by these two MDs.

## Raw Notes
**File List** (from gh api):
- docs/agentic-workflow-guide-generic.md
- docs/methodology.md (content identical to above)

**Key Excerpts**:

### Core Philosophy
```
Working with AI coding agents is like managing a team of highly capable but amnesiac junior developers. They can write excellent code, but they:
- Forget everything between sessions
- Get dumber as conversations get longer (context pollution)
- Will claim work is \"done\" when it isn't
...
**The Cardinal Rule: Fresh Sessions Are Free, Polluted Context Is Expensive**
```

### AGENTS.md Template (~110 lines)
```
## Testing Requirements
- Every new function requires tests
- Tests must pass before a task is considered complete
...
## The Rules
1. Agent proposes, human approves
...
```

### Example gates.md (SIMPLE)
```
# Verification Gates for Issue #47: User Email Validation
## Gate 1: Email validation enforced on save
**Verification type:** Test-based
...
## Complexity Assessment: SIMPLE
```

### Task Template
```
# Task N: [Brief description]
**Completes:** Gate N
## Implementation Steps
- [ ] Step one
## Completion Gate
- [ ] Assigned gate(s) verification passes
```

### Command Flows
- Simple: gates → tasks(1,2) → impl1 → commit → impl2 → commit → cleanup
- Complex: gates → task1 → impl1 → commit → task2 → ...

### Key Principles Summary (20 points)
1. Fresh sessions cheap...
20. Record architectural decisions (/wf-adr)...

Full contents fetched/stored in tool-results/b14bp3zqp.txt (agentic-workflow-guide-generic.md) and bv732fnxo.txt (methodology.md); identical comprehensive guide (~30KB each).