> 至上命題は [manifesto.md](manifesto.md) を参照。

# Core Philosophy & Design Principles

Working with AI coding agents is like managing a team of highly capable but amnesiac junior developers. This workflow mitigates their failure modes: forgetfulness, context pollution, premature completion claims, corner-cutting, and mess-leaving.

## Cardinal Rule

**Fresh Sessions Are Free, Polluted Context Is Expensive.**

Start a new session per task. Sessions are sticky notes, not notebooks — use one for a focused thought, throw it away, grab a new one. ~30 seconds to set context vs forgotten instructions, confused responses, wasted iterations.

## Human Cognitive Load

If humans cannot realistically review something, they will rubber-stamp it. This workflow sizes work for actual human attention:

- **1 Issue = 1 focus** — fits in working memory
- **1 Task = 1 Commit** — reviewable diffs in minutes, not hours
- **Gate-based verification** — clear pass/fail criteria, not subjective review
- **Three-phase cleanup** — audit, fix, then validate
- **Lightweight design docs** — 50-100 lines, not 2,000

## LLM Context Limits

LLM performance degrades as context grows (U-shaped attention curve). At ~50% of the context window, measurable degradation begins. By 65%, reliability drops significantly.

**The 50% rule:** When past 50% of context, finish current task and start a fresh session.

The workflow treats context management as architecture, not advice:

- Fresh session per task — context bounded by design
- Small task files — minimal context injection
- Implementation Notes — targeted memory, not full history
- Iterative planning (complex) — avoids stale plans
- On-demand design — not comprehensive upfront specs
- Summarise for handoff — checkpoint before degradation

## Work Unit Sizing

| Unit | Size | Purpose |
|------|------|---------|
| **Issue** | 1 focus | Clear objective |
| **Gate** | 1 verification criterion | Definition of done |
| **Task** | 50-200 lines, 1-5 files | Reviewable unit |
| **Commit** | 1 task | Atomic change |

---

## Key Principles Summary

1. **Fresh sessions are cheap, polluted context is expensive** — default to new sessions
2. **Hard gates, no exceptions** — task isn't done until gate passes, verified by you
3. **Human review at every phase boundary** — you are the quality gate
4. **Gates first, always** — define verification before planning
5. **Flexible verification** — tests, commands, or manual as appropriate
6. **One task, one commit** — reviewable units
7. **Complexity-aware planning** — simple: all upfront, complex: iteratively
8. **Respect splitting recommendations** — consider splits when detected
9. **Issues evolve, gates define done, tasks capture work**
10. **Agent proposes, human approves** — scope/deps/architecture need approval; commits are autonomous
11. **Protect the tests** — fix implementation, not test assertions
12. **When stuck, ask** — stop and ask rather than guessing
13. **Cleanup before PR, not after** — review branch with fresh eyes
14. **One issue at a time, constant re-evaluation**
15. **Know when to take the wheel** — 3 failures → summarise → fresh session → manual if still failing
16. **Don't reinvent the wheel** — use libraries and platform built-ins
17. **Summarise when context degrades** — checkpoint before starting fresh
18. **Use checkboxes for tracking** — `- [ ]` for all trackable items
19. **Validate before declaring done** — cleanup Phase 3 verifies all gates
20. **Record architectural decisions** — `/wf-adr` for patterns, technologies, deviations

See [agentic-workflow-guide.md](../agentic-workflow-guide.md) for full details.
