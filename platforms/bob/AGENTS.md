# AGENTS.md

## Testing Requirements

- Every new function requires tests
- Tests must pass before a task is considered complete
- Never delete, skip, or disable existing tests to make code "work"
- Never mock the thing you're testing
- If a test fails, fix the code or the test -- never remove it
- Never modify test assertions to match broken implementation
- Hardcoding expected values to force tests green is unacceptable
- Test behavior, not implementation details
- Include edge cases: empty inputs, nulls, boundary values
- Run the full test suite before claiming done
- If you added a feature, show the test that proves it works
- If you fixed a bug, show the test that would have caught it

## Test Hygiene

- Before writing a new test, check if an existing test already covers the scenario
- Prefer extending existing test files over creating new ones
- Consolidate tests that verify similar scenarios
- One test file per module/component (unless complexity requires splitting)
- Parameterized tests over copy-paste variations
- If a test file has multiple tests doing nearly the same thing, consolidate them
- Test file names should match the module they test (e.g., auth.test.ts for auth.ts)
- Redundant tests add maintenance burden without improving coverage -- remove them

## Verification Requirements

- Every task has explicit completion gates from gates.md
- Gates may be test-based, command-based, or manual review
- Complete verification as specified in the task's completion gate
- Never skip verification steps
- If gate verification fails, fix the implementation -- don't modify the gate
- Tests are ONE form of verification, not the only form
- Choose appropriate verification for the type of work:
  - Application code: tests
  - Infrastructure: commands (terraform plan, aws cli)
  - Configuration: validation scripts
  - Documentation: review checklists

## Code Quality

- Prefer simple, readable code over cleverness
- Make the minimal change necessary -- no unrequested features or refactors
- Don't refactor unrelated code without asking
- Before writing new code, check if existing code, libraries, or platform built-ins already do it
- If writing a utility that feels generic, check if it exists first
- Use the project's established patterns
- Composition over inheritance
- Keep functions and files small -- if getting long, split it

## Code Is Truth

- The codebase is the source of truth -- read code to understand behavior, don't assume
- Before modifying code, read and understand what it currently does

## Interface Stability

- Existing public interfaces are frozen unless explicitly approved
- Extend via new optional properties, not breaking changes
- Don't merge independent modules into coupled code
- Don't change function signatures that have existing callers

## Dependencies

- Never add new dependencies without asking
- When approved, use well-maintained libraries with active support
- Never use deprecated libraries or patterns
- If you identify a deprecated dependency, flag it immediately
- Prefer libraries with strong TypeScript/type support

## Documentation Hygiene

- Remove temporary comments before completing a task:
  - `// TODO`, `// FIXME`, `// HACK` (unless tracked in issue system)
  - `// testing`, `// new`, `// updated`, `// old code`
  - Commented-out code blocks
- Comments explain "why", not "what"
- When modifying a function, verify existing comments are still accurate
- When changing behavior, update relevant docs in the same task

## Completion Standards

A task is not complete until:
- All implementation steps are checked off
- All completion gates pass and are checked off
- All verification specified in gates.md passes
- Code is committed and PR is created (by vibe-local); paid AI reviews automatically, human makes final Merge decision
- No temporary code, debug logs, or commented-out code remains

## Commit Standards

- Each task = exactly one commit
- Commit size: 50-200 lines changed, 1-5 files touched
- If work would exceed this size, split into multiple tasks
- Commit message follows conventional commits format:
  - Type: feat, fix, refactor, test, docs, chore
  - Scope: component or module name
  - Description: what changed
  - Body: details about gates completed
- Never combine multiple unrelated changes in one commit
- Never split logically-connected changes across commits

## The Rules

1. **Agent proposes, human approves** -- All scope changes, dependency additions, and architectural decisions require explicit human approval. Commits and PR creation are performed autonomously by vibe-local; human approval is required for Merge only.
2. **Never bypass the human** -- When uncertain, ask rather than guessing
3. **Protect verification** -- Never modify gates, tests, or verification commands to make them pass; fix the implementation
4. **One task, one commit** -- Each task must be completable in a single reviewable commit
5. **Fresh session per task** -- When context feels polluted or after three failures, start a fresh session
6. **Follow the gates** -- Verification strategy is defined in gates.md, follow it exactly
7. **Track your work** -- Check off implementation steps and completion gates as you complete them
8. **Capture learnings** -- Record direction changes and discoveries in Implementation Notes
9. **No code in wrong phase** -- Design phase = signatures only, no implementation
10. **Investigate before guessing** -- When confused, run investigation phase instead of making assumptions

## Project-Specific Rules

- **Implementation role** -- This agent (vibe-local) performs implementation, commits, and PR creation autonomously. The human's role is Merge / Close judgment only.
- **Merge authority** -- Only the human has Merge authority. Never merge a PR autonomously.
- **Phase awareness** -- At the start of each session, read `docs/Contract.md` and determine the current phase before starting work.
- **3-failure rule** -- If the same problem fails 3 times, run `/wf-summarise` to create a handoff document, then start a fresh session. If it fails again in the fresh session, escalate to the human.
