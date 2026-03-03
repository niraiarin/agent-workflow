---
description: Create an Architecture Decision Record for significant decisions
argument-hint: <decision-title>
---

## Purpose

Research, evaluate, and document architectural decisions with explicit human approval. Prevents decision delegation by forcing structured consideration of alternatives before committing to an approach.

## CRITICAL: THIS IS A MULTI-TURN CONVERSATION

**You MUST stop and wait for user input at each phase boundary.**

This workflow has THREE mandatory checkpoints. You CANNOT skip them. You CANNOT combine phases. You CANNOT make the decision yourself.

If you find yourself writing a complete ADR with a decision without having asked the user which option to choose, **STOP IMMEDIATELY** -- you have violated the workflow.

---

## When to Use

- New abstraction or pattern being introduced
- Multiple viable implementation approaches with significant tradeoffs
- Technology or dependency choice
- Interface design that will be hard to change later
- Deviation from established codebase patterns
- Agent flags "this requires a decision" during implementation
- Reviewer spots undocumented architectural choice in PR

## When NOT to Use

- Obvious choices with no real alternatives
- Following established codebase patterns exactly
- Decisions already documented elsewhere (RFC, design doc)
- Trivial implementation details

## Command

```
/adr <decision-title>
```

Optional context flag when triggered from an issue:
```
/adr <decision-title> --issue <issue-identifier>
```

---

## Phase 0: Qualification Check

Before researching, evaluate whether this decision warrants an ADR.

### Steps

1. **Check "When to Use" criteria**
   - Does this match at least one of:
     - New abstraction or pattern being introduced
     - Multiple viable implementation approaches with significant tradeoffs
     - Technology or dependency choice
     - Interface design that will be hard to change later
     - Deviation from established codebase patterns
     - Agent flags "this requires a decision" during implementation
     - Reviewer spots undocumented architectural choice in PR

2. **Check "When NOT to Use" exclusions**
   - Is this any of these? (If yes, do NOT proceed with ADR)
     - Obvious choice with no real alternatives
     - Following established codebase patterns exactly
     - Decision already documented elsewhere (RFC, design doc)
     - Trivial implementation detail

3. **Check for existing documentation**
   - Is this decision already captured in an existing ADR, design doc, or RFC?

4. **Significance Test**

   Even if criteria match, the decision must be architecturally significant. Answer these:

   **Reversibility:** If we change this decision in 6 months, what breaks?
   - Multiple components need rewriting → SIGNIFICANT
   - One module needs updating → NOT SIGNIFICANT

   **Blast radius:** How many systems/components does this affect?
   - Cross-cutting (affects state, APIs, multiple services) → SIGNIFICANT
   - Single component or algorithm → NOT SIGNIFICANT

   **Dependency lock-in:** Does this create external constraints?
   - Third-party library, protocol, or API we must conform to → SIGNIFICANT
   - Internal pattern we fully control → NOT SIGNIFICANT

   **To qualify as an ADR, decision must be SIGNIFICANT in at least 2 of 3 tests.**

   Decisions that fail the significance test are implementation details. Document them in design docs, not ADRs.

### Phase 0 Output

Present qualification verdict:

> **ADR Qualification Assessment**
>
> **Decision:** [decision title]
>
> **Matches "When to Use" criteria:**
> - [x] [Criterion that applies] - [brief explanation]
> - [ ] [Criterion that doesn't apply]
>
> **Exclusions (any "Yes" disqualifies):**
> - Obvious choice with no real alternatives? [No/Yes]
> - Following established codebase patterns exactly? [No/Yes]
> - Already documented elsewhere? [No/Yes]
> - Trivial implementation detail? [No/Yes]
>
> **Significance Test (must pass 2 of 3):**
> - Reversibility: [SIGNIFICANT/NOT SIGNIFICANT] - [why]
> - Blast radius: [SIGNIFICANT/NOT SIGNIFICANT] - [why]
> - Dependency lock-in: [SIGNIFICANT/NOT SIGNIFICANT] - [why]
>
> **Verdict:** [QUALIFIES / DOES NOT QUALIFY]
>
> **Reasoning:** [1-2 sentences]

---

## ⛔ MANDATORY STOP 0

**DO NOT proceed to Phase 1 until the user confirms this warrants an ADR.**

If verdict is DOES NOT QUALIFY, suggest alternatives:
- "This appears to follow existing patterns. Consider just documenting in code comments."
- "This seems trivial. Proceed without ADR?"
- "This is already covered in [existing doc]. Reference that instead?"

**Violations:**
- ❌ Starting research without qualification check
- ❌ Proceeding when verdict is DOES NOT QUALIFY without user override

---

## Phase 1: Research (ONLY after user confirms qualification)

### Steps

1. **Understand the decision context**
   - What problem requires a decision?
   - What constraints exist (technical, organizational, timeline)?
   - What does the codebase currently do in similar situations?

2. **Identify decision drivers**
   - What factors matter for this decision?
   - What is the relative weight of each factor?
   - Which constraints are hard vs soft?

3. **Identify options**
   - Research viable approaches (minimum 2, typically 3-4)
   - Include "do nothing" or "minimal change" if applicable
   - Consider both internal patterns and industry approaches

4. **Research each option via subagents**

   For each identified option, spawn a subagent:
   ```xml
   <new_task>
   <mode>Advanced</mode>
   <message>
   ## Objective
   Research best practices and tradeoffs for specific approach

   ## Option
   [Option name - e.g., "JWT authentication", "URL path versioning"]

   ## Domain
   [Context - e.g., "REST API", "microservices", "web application"]

   ## Output
   Write to: .agents/research/adr-option-<option-name>.md

   ## Instructions
   1. Web search for "[option] best practices [domain]"
   2. Find authoritative sources (official docs, well-known blogs)
   3. Document pros, cons, and gotchas
   4. Note any migration or adoption considerations
   5. Write full findings to file using standard format
   6. Return 1-2 sentence summary only
   </message>
   </new_task>
   ```

   Wait for all subagents, read summaries, synthesize into tradeoff analysis.

### Phase 1 Output

Present ONLY the decision drivers (NOT the full ADR, NOT the options yet):

> "I've identified this as an architectural decision about [topic].
>
> Decision drivers I found:
> - [Driver 1] (weight: High/Medium/Low)
> - [Driver 2] (weight: High/Medium/Low)
> - [Driver 3] (weight: High/Medium/Low)
>
> Are these the right factors? Should I:
> - **Proceed** - drivers look correct, continue to options analysis
> - **Adjust weights** - [tell me which to change]
> - **Add drivers** - [tell me what's missing]
> - **Remove drivers** - [tell me which aren't relevant]"

---

## ⛔ MANDATORY STOP 1

**DO NOT proceed to Phase 2 until the user confirms drivers.**

You have completed Phase 1. STOP HERE. Wait for the user to approve decision drivers.

**Violations:**
- ❌ Presenting options without user confirmation of drivers
- ❌ Writing the full ADR document
- ❌ Making a recommendation

---

## Phase 2: Present Options (ONLY after user confirms drivers)

### Analyze tradeoffs

- Pros and cons for each option
- How each option addresses the decision drivers
- Expected consequences (positive, negative, risks)

### Phase 2 Output

Present the options analysis with your recommendation:

> **Option 1: [Name]**
> - Pros: [key advantages]
> - Cons: [key disadvantages]
>
> **Option 2: [Name]**
> - Pros: [key advantages]
> - Cons: [key disadvantages]
>
> **Option 3: [Name]**
> - Pros: [key advantages]
> - Cons: [key disadvantages]
>
> **My Recommendation:** Option [X] because [brief reasoning]
>
> **Which option do you want to proceed with?**
> - **Option 1** - [one-line summary]
> - **Option 2** - [one-line summary]
> - **Option 3** - [one-line summary]
> - **Need more research** - [tell me what's unclear]
>
> Please select and provide your rationale for the Decision section.

---

## ⛔ MANDATORY STOP 2

**DO NOT proceed to Phase 3 until the user selects an option AND provides rationale.**

You have completed Phase 2. STOP HERE. Wait for the user to choose.

**Violations:**
- ❌ Picking an option yourself
- ❌ Writing the ADR without user selection
- ❌ Proceeding without user-provided rationale

---

## Phase 3: Record (ONLY after user selects option and provides rationale)

### Pre-Record Checklist

Before writing the final ADR:

1. **Length check:** Will the ADR be under 150 lines?
   - If not, identify what to summarize or move to design doc

2. **Content check:** Does it contain ONLY template sections?
   - If not, remove or relocate extra content

3. **Template compliance:** All required sections present?

### Steps

After human selects option and provides rationale:

1. Write the complete ADR document using ONLY the template sections below
2. Update status to **Accepted**
3. Save to `docs/architecture/adrs/NNN-<decision-title>.md`
4. If linked to issue, reference in issue file
5. Remind human to update ADR README table

---

## ADR Content Requirements

The ADR document contains EXACTLY these sections, in this order:

### 1. Status
Format: `**Accepted**` with date

### 2. Context
- What situation requires this decision?
- What constraints exist?
- What is the current state?
- Keep under 30 lines

### 3. Decision Drivers
Table format with Weight column:
| Driver | Weight |
| ------ | ------ |
| [Factor] | High/Medium/Low |

### 4. Options Considered
For each option (minimum 2, typically 3-4):
- Brief description (2-3 sentences)
- **Pros:** 3-5 bullet points
- **Cons:** 3-5 bullet points

### 5. Agent Recommendation
- **Recommended:** Option [X]
- **Reasoning:** Why this option best addresses the decision drivers (3-5 sentences)
- **Caveats:** What could make this the wrong choice (2-3 bullets)

### 6. Decision
`**Use [Selected Option]** for [purpose/use case].`
_[Human fills in after selecting]_

### 7. Rationale
Numbered reasons why this option was chosen
_[Human fills in after selecting]_

### 8. Consequences
Agent fills in based on analysis:
- **Positive:** Expected benefits (3-5 bullets)
- **Negative:** Expected downsides (2-4 bullets)
- **Risks:** Known risks with mitigations (2-4 bullets)

### 9. References
Links to relevant documentation, articles, or resources

---

## STRICT: No Extra Content

The ADR contains ONLY the 9 sections listed above.

If you want to add something that doesn't fit in these sections, STOP and ask:
"I have additional information about [topic]. Should I create a separate design document?"

**Length target:** Total ADR under 150 lines.

---

## ADR Document Template

```markdown
# ADR-NNN: [Short Title]

## Status

**Accepted** - [date]

## Context

[What situation requires this decision? What constraints exist? What is the current state?]

## Decision Drivers

| Driver | Weight |
| ------ | ------ |
| [Factor 1] | High/Medium/Low |
| [Factor 2] | High/Medium/Low |
| [Factor 3] | High/Medium/Low |

## Options Considered

### Option 1: [Name]

**Pros:**
- Advantage 1
- Advantage 2

**Cons:**
- Disadvantage 1
- Disadvantage 2

### Option 2: [Name]

**Pros:**
- Advantage 1
- Advantage 2

**Cons:**
- Disadvantage 1
- Disadvantage 2

## Agent Recommendation

**Recommended:** Option [X]

**Reasoning:** [Why this option best addresses the decision drivers]

**Caveats:** [What could make this the wrong choice]

## Decision

**Use [Selected Option]** for [purpose/use case].

## Rationale

[User-provided rationale - numbered reasons why this option was chosen]

1. **Reason 1**: Explanation
2. **Reason 2**: Explanation

## Consequences

### Positive
- [Agent fills in expected benefits based on option analysis]

### Negative
- [Agent fills in expected downsides]

### Risks
- [Agent fills in risks with mitigations]

## References

- [Relevant documentation, articles, or resources]
```

---

## Output Location

```
docs/architecture/adrs/
  001-canvas-library.md
  002-state-management.md
  003-api-versioning.md
```

## ADR Numbering

Sequential numbering (001, 002, etc.) maintained by checking existing files in `docs/architecture/adrs/`.

---

## Integration Points

### From Issue Planning
When defining an issue reveals architectural uncertainty:
```
/wf-issue-plan
# Agent identifies: "This issue requires deciding between REST and GraphQL"
# Agent suggests: "Consider running /adr api-query-approach before proceeding"
```

### From Design Phase
When design phase surfaces multiple viable approaches:
```
/design issue-52
# Agent identifies decision point
# Agent: "Multiple valid approaches identified. Run /adr <title> to evaluate?"
```

### From Implementation
When implementation reveals unexpected decision:
```
/wf-03-implement issue-52 task-2
# Agent: "STOP - This requires an architectural decision: [description]"
# Agent: "Run /adr <title> before continuing"
```

### From Cleanup/Review
When reviewer spots undocumented decision:
```
/wf-04-cleanup issue-52
# Audit item: "New abstraction introduced without ADR - UserPermissionResolver pattern"
# Human: "Create ADR for that"
# /adr user-permission-resolution --issue issue-52
```

---

## What Makes a Good ADR

1. **Focused** - One decision per ADR
2. **Options are real** - Not strawmen to justify predetermined choice
3. **Tradeoffs are honest** - Every option has cons
4. **Drivers weighted** - Clear what matters most
5. **Context preserved** - Future readers understand why this mattered
6. **Consequences documented** - Both positive and negative outcomes

## Anti-Patterns

| Anti-Pattern | Problem | Instead |
|--------------|---------|---------|
| Single option presented | No real decision, just documentation | Require minimum 2 viable options |
| Strawman alternatives | Decision already made, ADR is theater | Options must be genuinely viable |
| Novel-length ADR | Won't be read or maintained | Keep under 150 lines |
| ADR after implementation | Decision already locked in | ADR before code, or accept tech debt |
| Skipping rationale | No audit trail for why | Require human to state reasoning |
| ADR for trivial choices | Process overhead without value | Reserve for significant decisions |
| All drivers "High" weight | No real prioritization | Force ranking of what matters most |
| Extra sections added | Scope creep, implementation details | Stick to the 9 template sections only |

## Lifecycle

```
Proposed  ->  Accepted   ->  [Superseded by ADR-XXX]
          ->  Rejected       [Deprecated]
```

When a later decision changes an earlier one:
1. Update the original ADR status to **Superseded by ADR-XXX**
2. Link to the PR that made the change
3. Reference the original ADR in the new ADR's Context section

## Checklist Before Merge

When an ADR is accepted:

- [ ] Status updated to **Accepted** with PR link
- [ ] ADR README table updated with new entry
- [ ] AGENTS.md updated if ADR introduces new standards/constraints
- [ ] Related issue/task references added

$ARGUMENTS
