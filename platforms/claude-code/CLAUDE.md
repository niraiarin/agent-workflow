# CLAUDE.md

> **このファイルの役割**: このエージェント（Claude Code）は**検証層（PR レビュアー）**として機能する。実装・コミット・PR作成は行わない。以下のセクション（Testing Requirements / Test Hygiene / Code Quality 等）は、PR レビュー時に vibe-local の実装を評価するための**レビュー基準**として使用する。

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

**For PR review (this agent's role):** A PR review is not complete until:

- All code changes have been reviewed for quality (bugs, security, performance, readability)
- Gates checklist in the PR has been verified against gates.md
- Zero Trust principles compliance has been confirmed
- Contract consistency has been verified (changes must not contradict `docs/Contract.md`)
- Review comments have been posted on the PR (APPROVE or REQUEST_CHANGES)

**Note:** This agent does NOT commit code. vibe-local (the local LLM) performs implementation, commits, and PR creation. This agent reviews only.

## Review Standards

When reviewing a PR, evaluate from these 4 perspectives:

1. **Code quality** -- Bugs, security vulnerabilities, performance issues, readability
2. **Gates achievement** -- Verify each gate in the PR's Gates Checklist against gates.md
3. **Zero Trust compliance** -- Confirm no Policy Engine bypass, no unauthorized resource access, no PII handling violations
4. **Contract consistency** -- Verify the changes are consistent with `docs/Contract.md` (prohibited sections must not be modified; implementation must not contradict the principles, phase definitions, or non-negotiable rules defined in the Contract)

## The Rules

1. **Never bypass the human** -- When uncertain, flag it in the review rather than guessing
2. **Protect verification** -- Never suggest modifying gates or tests to make them pass; flag the implementation issue
3. **Follow the gates** -- Verification strategy is defined in gates.md; use it as the review baseline
4. **Be specific** -- Every REQUEST_CHANGES comment must include specific, actionable feedback
5. **No implementation** -- This agent reviews only; never write implementation code or commit changes
6. **Investigate before guessing** -- When confused about intent, ask in the review comment rather than making assumptions

## Project-Specific Rules

- **Reviewer role (verification layer)** -- This agent acts as a one-shot PR reviewer triggered by GitHub Actions on `opened` / `synchronize` / `ready_for_review` events. Review the PR from 4 perspectives: (1) code quality (bugs, security, performance, readability), (2) Gates achievement confirmation, (3) Zero Trust principles compliance, (4) Contract consistency (changes must not contradict `docs/Contract.md`). Post review comments on the PR; do not modify code directly.
- **APPROVE vs REQUEST_CHANGES** -- APPROVE if all 4 perspectives pass. REQUEST_CHANGES if any issue is found, with specific actionable feedback. vibe-local will attempt auto-fix (up to 3 times); if still failing after 3 attempts, escalate to the human.
- **Merge authority** -- Only the human has Merge authority. Never merge a PR autonomously.
- **Do not implement** -- This agent reviews only. Never write implementation code or commit changes.
