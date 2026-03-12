# Command Reference

All commands use slash-command syntax (no flags).

## Core Workflow

| Command | Arguments | Output | Purpose | Prerequisites |
|---------|-----------|--------|---------|---------------|
| `/wf-01-define-gates` | `<issue-identifier>` | `gates.md` | Define verification strategy and complexity | Issue exists |
| `/wf-15-define-test-cases` | `<issue-identifier>` | `test-cases.md` | Concrete test cases for Test-based Gates | `gates.md` with Test-based Gates |
| `/wf-02-task-plan` | `<issue-identifier>` | `task-N.md` | Plan implementation tasks (SIMPLE: all, COMPLEX: next) | `gates.md` exists |
| `/wf-03-implement` | `<issue-identifier> <task-identifier>` | Code + commit + PR | Execute task, verify gates, commit | `task-N.md` exists |
| `/wf-04-cleanup` | `<issue-identifier>` | Cleanup commit + PR | Audit/fix/validate before merge | All tasks committed |

## Optional On-Demand

| Command | Arguments | Output | Purpose | Prerequisites |
|---------|-----------|--------|---------|---------------|
| `/wf-00-intake` | (interactive) | Well-formed issue | Receive request, clarify intent, validate | None |
| `/wf-issue-plan` | (interactive) | Issue definition | Define new issue with scope and criteria | None |
| `/wf-investigate` | `<issue-identifier>` | Investigation notes | Explore codebase, document findings | Issue exists |
| `/wf-design` | `<issue-identifier>` | Design doc (50-100 lines) | Interface design — signatures only, no code | Can't write meaningful gates |
| `/wf-adr` | `<decision-title>` | ADR document (MADR format) | Record architectural decisions | Multiple viable approaches |
| `/wf-summarise` | `[<issue-identifier> <task-identifier>]` | Handoff notes | Checkpoint session for handoff | Context degraded or switching |
| `/wf-workflow` | (none) | Explanation | Explain workflow methodology | None |
| `/wf-self-improve` | `<issue-identifier>` | Improvement proposals | Retrospective on completed issue cycle | After `wf-04-cleanup` |

## Output Locations

All workflow artifacts are stored under `.agents/`:

```
.agents/
├── issues/                          # Issue definitions (if not on GitHub)
├── tasks/<issue>/
│   ├── gates.md                     # Verification gates
│   ├── test-cases.md                # Test case definitions
│   ├── task-1.md ... task-N.md      # Task plans
│   └── investigation.md            # Investigation notes
├── research/                        # Subagent research files
├── reviews/                         # Review results
└── metrics/                         # Workflow metrics
```

See [how-to/phases.md](../how-to/phases.md) for phase-by-phase execution details.
