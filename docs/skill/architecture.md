# Skill Architecture — Enhanced Skill Creator Design Specification

> **Role of this document:** Primary knowledge base and design specification for the enhanced-skill-creator skill (`.skills/enhanced-skill-creator/`). All design decisions, methodology, and quality standards defined here are authoritative. The skill's SKILL.md references this document; individual sections are loaded via progressive disclosure as needed.

---

## Contents

1. [Design Goals](#design-goals)
2. [Skill Fundamentals](#skill-fundamentals)
3. [Planning and Design](#planning-and-design)
4. [Testing and Iteration](#testing-and-iteration)
5. [Distribution and Sharing](#distribution-and-sharing)
6. [Patterns and Troubleshooting](#patterns-and-troubleshooting)
7. [Resources and References](#resources-and-references)
8. [Appendix A: Quality Checklist](#appendix-a-quality-checklist)
9. [Appendix B: YAML Frontmatter Schema](#appendix-b-yaml-frontmatter-schema)
10. [Appendix C: Complete Skill Examples](#appendix-c-complete-skill-examples)
11. [Appendix D: Environment-Specific Capabilities](#appendix-d-environment-specific-capabilities)
12. [Appendix E: Eval Quality Standards](#appendix-e-eval-quality-standards)

---

## Design Goals

This section defines what the enhanced-skill-creator aims to achieve beyond the existing `example-skills:skill-creator`.

### Core Philosophy

A **skill** is a set of instructions — packaged as a folder — that teaches Claude how to handle specific tasks or workflows. Skills encode repeatable workflows: frontend design from specs, document generation following style guides, multi-step processes with consistent methodology, MCP-enhanced automation.

### Enhanced Skill Creator — Differentiators

The enhanced-skill-creator builds on the existing skill-creator's iteration loop (draft → test → review → improve) with deeper design knowledge:

| Capability | Existing skill-creator | Enhanced skill-creator |
|---|---|---|
| Skill drafting | Template-based generation | Design-principle-driven generation, grounded in this spec |
| Instruction writing | Follows user direction | Applies "Explain the Why" philosophy; flags rigid MUST/NEVER anti-patterns |
| Description optimization | `run_loop.py` trigger testing | Same + near-miss negative design, pushiness calibration |
| Test query design | User-provided or generated | Realistic queries with context, near-miss negatives, train/test split |
| Skill improvement | Feedback-driven edits | Anti-overfitting principles; transcript analysis; script bundling discovery |
| Conversation extraction | Not supported | Extract workflows from existing Claude conversations |
| Environment awareness | Claude Code focused | Adapts workflow to Claude.ai / Claude Code / API capabilities |

### Design Principles

1. **Generalize over memorize** — Skills serve millions of invocations. Every instruction must work across diverse prompts, not just test cases.
2. **Explain the why** — Context-rich instructions outperform rigid commands. Claude reasons better when it understands intent.
3. **Lean over thorough** — Remove instructions that don't pull their weight. Shorter skills with clear reasoning beat verbose skills with rigid rules.
4. **Human-in-the-loop** — Every iteration includes human review. Automated metrics complement but never replace human judgment.
5. **Anti-overfitting** — Train/test splits for descriptions. Generalize from failures rather than patching specific cases.
6. **Category-appropriate tooling** — CLI integration expectations vary by skill category. Category 1 (creation) skills may rely solely on Claude's built-in capabilities. Category 2 (workflow) skills should extract deterministic subtasks to CLI tools. Category 3 (MCP enhancement) skills legitimately depend on MCP servers. See [Implementation Boundaries](../explanation/implementation-boundaries.md) for detailed guidance.

---

## Skill Fundamentals

### What is a skill?

A skill is a folder containing:

- **SKILL.md** (required): Instructions in Markdown with YAML frontmatter
- **scripts/** (optional): Executable code (Python, Bash, etc.)
- **references/** (optional): Documentation loaded as needed
- **assets/** (optional): Templates, fonts, icons used in output

### Core Design Principles

#### Progressive Disclosure

Skills use a three-level system:

- **First level (YAML frontmatter):** Always loaded in Claude's system prompt. Provides just enough information for Claude to know when each skill should be used without loading all of it into context.
- **Second level (SKILL.md body):** Loaded when Claude thinks the skill is relevant to the current task. Contains the full instructions and guidance.
- **Third level (Linked files):** Additional files bundled within the skill directory that Claude can choose to navigate and discover only as needed.

This progressive disclosure minimizes token usage while maintaining specialized expertise.

#### Composability

Claude can load multiple skills simultaneously. Your skill should work well alongside others, not assume it's the only capability available.

#### Portability

Skills work identically across Claude.ai, Claude Code, and API. Create a skill once and it works across all surfaces without modification, provided the environment supports any dependencies the skill requires.

#### Principle of Lack of Surprise

A skill's contents should not surprise the user in their intent if described. Skills must not contain malware, exploit code, or any content that could compromise system security. When someone reads your skill's description and then looks at its actual contents, there should be no gap between what was promised and what exists.

### For MCP Builders: Skills + Connectors

> Building standalone skills without MCP? Skip to [Planning and Design](#planning-and-design).

If you already have a working MCP server, you've done the hard part. Skills are the knowledge layer on top — capturing the workflows and best practices you already know, so Claude can apply them consistently.

#### The kitchen analogy

- **MCP provides the professional kitchen:** access to tools, ingredients, and equipment.
- **Skills provide the recipes:** step-by-step instructions on how to create something valuable.

Together, they enable users to accomplish complex tasks without needing to figure out every step themselves.

#### How they work together

| MCP (Connectivity) | Skills (Knowledge) |
|---|---|
| Connects Claude to your service (Notion, Asana, Linear, etc.) | Teaches Claude how to use your service effectively |
| Provides real-time data access and tool invocation | Captures workflows and best practices |
| What Claude **can** do | How Claude **should** do it |

#### Why this matters for your MCP users

**Without skills:**

- Users connect your MCP but don't know what to do next
- Support tickets asking "how do I do X with your integration"
- Each conversation starts from scratch
- Inconsistent results because users prompt differently each time
- Users blame your connector when the real issue is workflow guidance

**With skills:**

- Pre-built workflows activate automatically when needed
- Consistent, reliable tool usage
- Best practices embedded in every interaction
- Lower learning curve for your integration

---

## Planning and Design

### Start with use cases

Every skill begins with 2–3 concrete use cases. The enhanced-skill-creator must elicit these during the intent-capture phase.

**Capturing workflows from existing conversations:** When a user has already built a working workflow interactively, extract it directly. Identify: the tools used, the sequence of steps, corrections made, and input/output formats observed. Fill gaps and confirm before proceeding.

**Good use case definition:**

```
Use Case: Project Sprint Planning
Trigger: User says "help me plan this sprint" or "create sprint tasks"
Steps:
  1. Fetch current project status from Linear (via MCP)
  2. Analyze team velocity and capacity
  3. Suggest task prioritization
  4. Create tasks in Linear with proper labels and estimates
Result: Fully planned sprint with tasks created
```

**Ask yourself:**

- What does a user want to accomplish?
- What multi-step workflows does this require?
- Which tools are needed (built-in or MCP?)
- What domain knowledge or best practices should be embedded?

### Common skill use case categories

At Anthropic, we've observed three common use cases:

#### Category 1: Document & Asset Creation

**Used for:** Creating consistent, high-quality output including documents, presentations, apps, designs, code, etc.

**Real example:** frontend-design skill (also see skills for docx, pptx, xlsx, and ppt)

> "Create distinctive, production-grade frontend interfaces with high design quality. Use when building web components, pages, artifacts, posters, or applications."

**Key techniques:**

- Embedded style guides and brand standards
- Template structures for consistent output
- Quality checklists before finalizing
- No external tools required — uses Claude's built-in capabilities

#### Category 2: Workflow Automation

**Used for:** Multi-step processes that benefit from consistent methodology, including coordination across multiple MCP servers.

**Real example:** skill-creator skill

> "Interactive guide for creating new skills. Walks the user through use case definition, frontmatter generation, instruction writing, and validation."

**Key techniques:**

- Step-by-step workflow with validation gates
- Templates for common structures
- Built-in review and improvement suggestions
- Iterative refinement loops

#### Category 3: MCP Enhancement

**Used for:** Workflow guidance to enhance the tool access an MCP server provides.

**Real example:** sentry-code-review skill (from Sentry)

> "Automatically analyzes and fixes detected bugs in GitHub Pull Requests using Sentry's error monitoring data via their MCP server."

**Key techniques:**

- Coordinates multiple MCP calls in sequence
- Embeds domain expertise
- Provides context users would otherwise need to specify
- Error handling for common MCP issues

### Define success criteria

The enhanced-skill-creator elicits these metrics during intent capture. They serve as targets during the iteration loop — rough benchmarks, not precise thresholds. Qualitative human judgment always supplements quantitative metrics.

#### Quantitative metrics

- **Skill triggers on 90% of relevant queries**
  - *How to measure:* Run 10–20 test queries that should trigger your skill. Track how many times it loads automatically vs. requires explicit invocation.
- **Completes workflow in X tool calls**
  - *How to measure:* Compare the same task with and without the skill enabled. Count tool calls and total tokens consumed.
- **0 failed API calls per workflow**
  - *How to measure:* Monitor MCP server logs during test runs. Track retry rates and error codes.

#### Qualitative metrics

- **Users don't need to prompt Claude about next steps**
  - *How to assess:* During testing, note how often you need to redirect or clarify. Ask beta users for feedback.
- **Workflows complete without user correction**
  - *How to assess:* Run the same request 3–5 times. Compare outputs for structural consistency and quality.
- **Consistent results across sessions**
  - *How to assess:* Can a new user accomplish the task on first try with minimal guidance?

### Technical requirements

#### File structure

```
your-skill-name/
├── SKILL.md             # Required - main skill file
├── scripts/             # Optional - executable code
│   ├── process_data.py  # Example
│   └── validate.sh      # Example
├── references/          # Optional - documentation
│   ├── api-guide.md     # Example
│   └── examples/        # Example
└── assets/              # Optional - templates, etc.
    └── report-template.md # Example
```

#### Critical rules

**SKILL.md naming:**

- Must be exactly `SKILL.md` (case-sensitive)
- No variations accepted (`SKILL.MD`, `skill.md`, etc.)

**Skill folder naming:**

- Use kebab-case: `notion-project-setup` ✅
- No spaces: `Notion Project Setup` ❌
- No underscores: `notion_project_setup` ❌
- No capitals: `NotionProjectSetup` ❌

**No README.md:**

- Don't include `README.md` inside your skill folder
- All documentation goes in `SKILL.md` or `references/`
- Note: when distributing via GitHub, you'll still want a repo-level README for human users — see [Distribution and Sharing](#chapter-4-distribution-and-sharing).

### YAML frontmatter: The most important part

The YAML frontmatter is how Claude decides whether to load your skill. Get this right.

#### Minimal required format

```yaml
---
name: your-skill-name
description: What it does. Use when user asks to [specific phrases].
---
```

That's all you need to start.

#### Field requirements

**name** (required):

- kebab-case only
- No spaces or capitals
- Should match folder name

**description** (required):

- MUST include BOTH:
  - What the skill does
  - When to use it (trigger conditions)
- Under 1024 characters
- No XML tags (`<` or `>`)
- Include specific tasks users might say
- Mention file types if relevant

**license** (optional):

- Use if making skill open source
- Common: `MIT`, `Apache-2.0`

**compatibility** (optional):

- 1–500 characters
- Indicates environment requirements: e.g. intended product, required system packages, network access needs, etc.

**metadata** (optional):

- Any custom key-value pairs
- Suggested: `author`, `version`, `mcp-server`
- Example:

```yaml
metadata:
  author: ProjectHub
  version: 1.0.0
  mcp-server: projecthub
```

#### Security restrictions

**Forbidden in frontmatter:**

- XML angle brackets (`<` `>`)
- Skills with "claude" or "anthropic" in name (reserved)

**Why:** Frontmatter appears in Claude's system prompt. Malicious content could inject instructions.

### Writing effective skills

#### The description field

According to Anthropic's engineering blog: "This metadata...provides just enough information for Claude to know when each skill should be used without loading all of it into context." This is the first level of progressive disclosure.

**Structure:**

```
[What it does] + [When to use it] + [Key capabilities]
```

**Write descriptions with "push":** Claude currently has a tendency to **undertrigger** skills — to not use them when they would be helpful. To combat this, make descriptions slightly assertive. Instead of just describing what the skill does, actively claim the contexts where it should be used.

```yaml
# Passive (undertriggers)
description: How to build a dashboard to display internal data.

# Pushy (better triggering)
description: How to build a dashboard to display internal data. Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of company data, even if they don't explicitly ask for a "dashboard."
```

**Examples of good descriptions:**

```yaml
# Good - specific and actionable
description: Analyzes Figma design files and generates developer handoff documentation. Use when user uploads .fig files, asks for "design specs", "component documentation", or "design-to-code handoff".

# Good - includes trigger phrases
description: Manages Linear project workflows including sprint planning, task creation, and status tracking. Use when user mentions "sprint", "Linear tasks", "project planning", or asks to "create tickets".

# Good - clear value proposition
description: End-to-end customer onboarding workflow for PayFlow. Handles account creation, payment setup, and subscription management. Use when user says "onboard new customer", "set up subscription", or "create PayFlow account".
```

**Examples of bad descriptions:**

```yaml
# Too vague
description: Helps with projects.

# Missing triggers
description: Creates sophisticated multi-page documentation systems.

# Too technical, no user triggers
description: Implements the Project entity model with hierarchical relationships.
```

#### Writing the main instructions

After the frontmatter, write the actual instructions in Markdown.

**Recommended structure:**

*Adapt this template for your skill. Replace bracketed sections with your specific content.*

```markdown
---
name: your-skill
description: [...]
---

# Your Skill Name

## Instructions

### Step 1: [First Major Step]
Clear explanation of what happens.

Example:
```bash
python scripts/fetch_data.py --project-id PROJECT_ID
```
Expected output: [describe what success looks like]

(Add more steps as needed)

## Examples

### Example 1: [common scenario]

User says: "Set up a new marketing campaign"

Actions:
1. Fetch existing campaigns via MCP
2. Create new campaign with provided parameters

Result: Campaign created with confirmation link

(Add more examples as needed)

## Troubleshooting

### Error: [Common error message]
**Cause:** [Why it happens]
**Solution:** [How to fix]

(Add more error cases as needed)
```

#### Instruction Writing Philosophy: Explain the Why

The most important principle for writing skill instructions: **explain why, not just what.** Today's LLMs are smart — they have good theory of mind and, when given a good harness, can go beyond rote instructions and genuinely reason about the task.

If you find yourself writing ALWAYS or NEVER in all caps, or using super rigid structures, that's a yellow flag. Reframe and explain the reasoning so the model understands why the thing you're asking for is important. That's a more humane, powerful, and effective approach.

```markdown
# Weak — rigid command without context
ALWAYS validate input before processing. NEVER skip this step.

# Strong — explains the why, model can generalize
Before processing, validate the input data. Malformed input causes silent
failures downstream — a missing date field, for instance, will produce a
report with blank columns that the user won't notice until they present it.
Check for: non-empty required fields, valid date formats (YYYY-MM-DD),
and numeric ranges within expected bounds.
```

When the model understands the reasoning, it can handle edge cases the skill author never anticipated, because it understands the *intent* behind the instruction.

#### Best Practices for Instructions

**Be Specific and Actionable**

✅ Good:

```
Run `python scripts/validate.py --input {filename}` to check data format.
If validation fails, common issues include:
- Missing required fields (add them to the CSV)
- Invalid date formats (use YYYY-MM-DD)
```

❌ Bad:

```
Validate the data before proceeding.
```

**Include error handling**

```markdown
## Common Issues

### MCP Connection Failed
If you see "Connection refused":
1. Verify MCP server is running: Check Settings > Extensions
2. Confirm API key is valid
3. Try reconnecting: Settings > Extensions > [Your Service] > Reconnect
```

**Reference bundled resources clearly**

```
Before writing queries, consult `references/api-patterns.md` for:
- Rate limiting guidance
- Pagination patterns
- Error codes and handling
```

**Use progressive disclosure**

Keep SKILL.md focused on core instructions. Move detailed documentation to `references/` and link to it. (See [Core Design Principles](#core-design-principles) for how the three-level system works.)

---

## Testing and Iteration

Testing rigor scales with skill visibility. The enhanced-skill-creator adapts its methodology to the environment (see [Appendix D](#appendix-d-environment-specific-capabilities)):

- **Manual testing (Claude.ai)** — Direct queries, observe behavior. Fast iteration, no setup.
- **Scripted testing (Claude Code)** — Automated test cases via subagents. Repeatable validation.
- **Programmatic testing (API)** — Evaluation suites against defined test sets.

> **Single-task-first principle:** Iterate on one challenging task until Claude succeeds, then extract the winning approach into the skill. Only after a working foundation exists should the test set expand.

### The Core Iteration Loop

The most effective skill development follows a concrete loop:

```
1. Draft (or edit) the skill
2. Run Claude-with-skill on 2–3 test prompts
3. Review outputs with a human — qualitative and quantitative
4. Improve the skill based on feedback
5. Repeat until satisfied
6. Expand the test set and try again at larger scale
```

**Key insight:** Start by iterating on a single challenging task until Claude succeeds, then extract the winning approach into the skill. Only after you have a working foundation should you expand to multiple test cases for coverage. This leverages Claude's in-context learning and provides faster signal than broad testing.

### Recommended Testing Approach

Based on early experience, effective skills testing typically covers three areas:

#### 1. Triggering tests

**Goal:** Ensure your skill loads at the right times.

**Understanding how triggering works:** Skills appear in Claude's `available_skills` list with their name + description. Claude decides whether to consult a skill based on that description. Critically, **Claude only consults skills for tasks it can't easily handle on its own** — simple, one-step queries like "read this PDF" may not trigger a skill even if the description matches perfectly, because Claude can handle them directly with basic tools. Complex, multi-step, or specialized queries reliably trigger skills when the description matches.

This means your test queries should be substantive enough that Claude would actually benefit from consulting a skill.

**Test cases:**

- ✅ Triggers on obvious tasks
- ✅ Triggers on paraphrased requests
- ❌ Doesn't trigger on unrelated topics

#### Designing good test queries

Test queries must be **realistic** — the kind of thing a real user would actually type. Include file paths, personal context, column names, company names. Some should be in lowercase, contain abbreviations or typos or casual speech. Use a mix of different lengths.

**For should-trigger queries (8–10):** Different phrasings of the same intent — some formal, some casual. Include cases where the user doesn't explicitly name the skill but clearly needs it.

**For should-NOT-trigger queries (8–10):** The most valuable ones are **near-misses** — queries that share keywords or concepts with the skill but actually need something different. Don't make them obviously irrelevant.

```
# Bad negative test — too easy, tests nothing
- "Write a fibonacci function"

# Good negative test — shares keywords but needs different skill
- "I have a spreadsheet with project timelines, can you make a gantt chart?"
  (shares "project" keyword with ProjectHub, but is a visualization task)
```

**Example test suite with realistic queries:**

```
Should trigger:
- "ok so I just joined the marketing team and need to set up our Q4 planning
   workspace in ProjectHub — the one with the campaign tracker template"
- "can you create a projecthub project? need it for the API migration,
   about 15 tasks, eng team alpha"
- "Initialize a ProjectHub project for Q4 planning"

Should NOT trigger:
- "I need to update the project timeline in my spreadsheet"
- "Help me write a Python script to track project status"
- "Create a spreadsheet with project milestones"
```

#### Train/test split for description optimization

When optimizing your description, split test queries into **60% train / 40% held-out test**. Improve the description based on train failures, but select the best version by test score. This prevents overfitting to specific phrasings.

#### 2. Functional tests

**Goal:** Verify the skill produces correct outputs.

**Test cases:**

- Valid outputs generated
- API calls succeed
- Error handling works
- Edge cases covered

**Example:**

```
Test: Create project with 5 tasks
Given: Project name "Q4 Planning", 5 task descriptions
When: Skill executes workflow
Then:
  - Project created in ProjectHub
  - 5 tasks created with correct properties
  - All tasks linked to project
  - No API errors
```

#### 3. Performance comparison

**Goal:** Prove the skill improves results vs. baseline.

Use the metrics from [Define Success Criteria](#define-success-criteria). Here's what a comparison might look like.

**Baseline comparison:**

```
Without skill:
- User provides instructions each time
- 15 back-and-forth messages
- 3 failed API calls requiring retry
- 12,000 tokens consumed

With skill:
- Automatic workflow execution
- 2 clarifying questions only
- 0 failed API calls
- 6,000 tokens consumed
```

#### 4. Blind A/B comparison (advanced)

For rigorous comparison between two versions of a skill: give two outputs to an independent evaluator without revealing which is which, and let it judge quality. This removes bias toward the version you expect to be better.

The evaluator generates a rubric based on the task (content: correctness/completeness/accuracy; structure: organization/formatting/usability), scores each output, and determines a winner. Post-hoc analysis then "unblinds" the results and examines the skills and execution transcripts to identify *why* the winner won — producing actionable improvement suggestions.

#### 5. Transcript analysis

Don't just look at final outputs — **read the execution transcripts.** Observe:

- How closely did Claude follow the skill's instructions?
- Did it waste time on unproductive steps?
- Did it use the skill's bundled scripts, or reinvent them?
- Where did it diverge from the intended workflow?

If the skill is making Claude waste time doing unproductive things, remove those parts and see what happens. If all test runs independently wrote similar helper scripts (e.g., all three created a `create_docx.py`), that's a strong signal the skill should **bundle that script**. Write it once, put it in `scripts/`, and tell the skill to use it.

### Enhanced Skill Creator — Methodology Integration

The enhanced-skill-creator implements the full methodology defined in this specification. Its workflow phases map to this document as follows:

| Phase | Methodology Source | Key Sections |
|---|---|---|
| **1. Intent Capture** | [Start with use cases](#start-with-use-cases), [Conversation extraction](#pattern-6-conversation-to-skill-extraction) | Elicit use cases, extract from conversations |
| **2. Skill Drafting** | [Writing effective skills](#writing-effective-skills), [Instruction Philosophy](#instruction-writing-philosophy-explain-the-why) | Generate SKILL.md with "Explain the Why" approach |
| **3. Description Optimization** | [The description field](#the-description-field), [Train/test split](#traintest-split-for-description-optimization) | Pushiness calibration, near-miss negatives |
| **4. Testing** | [Core Iteration Loop](#the-core-iteration-loop), [Triggering tests](#1-triggering-tests) | Realistic query design, blind A/B, transcript analysis |
| **5. Improvement** | [Principles for improving](#principles-for-improving-skills-without-overfitting) | Anti-overfitting, script bundling, lean revision |
| **6. Distribution** | [Distribution and Sharing](#distribution-and-sharing) | Packaging, positioning |

**Capabilities beyond the base skill-creator:**

- Design-principle-driven generation grounded in this spec
- Automatic detection and flagging of rigid MUST/NEVER anti-patterns in instructions
- Near-miss negative test query generation for description optimization
- Conversation-to-skill extraction workflow
- Environment-adaptive methodology (Claude.ai / Claude Code / API)

### Iteration based on feedback

Skills are living documents. Plan to iterate based on:

**Undertriggering signals:**

- Skill doesn't load when it should
- Users manually enabling it
- Support questions about when to use it

> **Solution:** Add more detail and nuance to the description — this may include keywords particularly for technical terms

**Overtriggering signals:**

- Skill loads for irrelevant queries
- Users disabling it
- Confusion about purpose

> **Solution:** Add negative triggers, be more specific

**Execution issues:**

- Inconsistent results
- API call failures
- User corrections needed

> **Solution:** Improve instructions, add error handling

### Principles for improving skills without overfitting

When improving a skill based on test results, the temptation is to add fiddly, case-specific fixes. Resist it. Skills are meant to be used millions of times across diverse prompts — if it only works for your test cases, it's useless.

**1. Generalize from feedback.** Don't put in fiddly overfit changes or oppressively constrictive MUSTs. If there's a stubborn issue, try different metaphors, different patterns, or a structural change. It's relatively cheap to try.

**2. Keep the skill lean.** Remove things that aren't pulling their weight. If test transcripts show the model wasting time on instructions that don't help, remove those instructions and observe the effect.

**3. Explain the why.** Try hard to explain the *reason* behind everything. When given good context, Claude can go beyond rote instructions and genuinely solve problems. A well-explained instruction is more powerful and general than an unexplained command.

**4. Look for repeated work across test cases.** Read the transcripts and notice if Claude independently wrote similar helper scripts across different test cases. If all 3 tests resulted in writing a `create_docx.py`, that's a signal to bundle the script in `scripts/`.

**5. Avoid description overfitting.** Don't respond to trigger failures by adding an ever-expanding list of specific queries to the description. Instead, generalize from the failures to broader categories of user intent. Descriptions should stay under 100–200 words even if that comes at the cost of accuracy on specific edge cases.

---

## Distribution and Sharing

The enhanced-skill-creator handles packaging and provides distribution guidance as its final phase.

### Current distribution model

**How individual users get skills:**

1. Download the skill folder
2. Zip the folder (if needed)
3. Upload to Claude.ai via Settings > Capabilities > Skills
4. Or place in Claude Code skills directory

**Organization-level skills:**

- Admins can deploy skills workspace-wide (shipped December 18, 2025)
- Automatic updates
- Centralized management

### An open standard

We've published Agent Skills as an open standard. Like MCP, we believe skills should be portable across tools and platforms — the same skill should work whether you're using Claude or other AI platforms. That said, some skills are designed to take full advantage of a specific platform's capabilities; authors can note this in the skill's `compatibility` field. We've been collaborating with members of the ecosystem on the standard, and we're excited by early adoption.

### Using skills via API

For programmatic use cases — such as building applications, agents, or automated workflows that leverage skills — the API provides direct control over skill management and execution.

**Key capabilities:**

- `/v1/skills` endpoint for listing and managing skills
- Add skills to Messages API requests via the `container.skills` parameter
- Version control and management through the Claude Console
- Works with the Claude Agent SDK for building custom agents

**When to use skills via the API vs. Claude.ai:**

| Use Case | Best Surface |
|---|---|
| End users interacting with skills directly | Claude.ai / Claude Code |
| Manual testing and iteration during development | Claude.ai / Claude Code |
| Individual, ad-hoc workflows | Claude.ai / Claude Code |
| Applications using skills programmatically | API |
| Production deployments at scale | API |
| Automated pipelines and agent systems | API |

> **Note:** Skills in the API require the Code Execution Tool beta, which provides the secure environment skills need to run.

For implementation details, see:

- Skills API Quickstart
- Create Custom Skills
- Skills in the Agent SDK

### Recommended approach today

For open-source distribution: host on GitHub with a public repo, clear README (separate from the skill folder — skill folders must not contain `README.md`), and example usage with screenshots.

**1. Host on GitHub**

- Public repo for open-source skills
- Clear README with installation instructions
- Example usage and screenshots

**2. Document in Your MCP Repo**

- Link to skills from MCP documentation
- Explain the value of using both together
- Provide quick-start guide

**3. Create an Installation Guide**

```markdown
## Installing the [Your Service] skill

1. Download the skill:
   - Clone repo: `git clone https://github.com/yourcompany/skills`
   - Or download ZIP from Releases

2. Install in Claude:
   - Open Claude.ai > Settings > Skills
   - Click "Upload skill"
   - Select the skill folder (zipped)

3. Enable the skill:
   - Toggle on the [Your Service] skill
   - Ensure your MCP server is connected

4. Test:
   - Ask Claude: "Set up a new project in [Your Service]"
```

### Positioning guidance

When the enhanced-skill-creator generates README or documentation for a skill, apply these principles.

**Focus on outcomes, not features:**

✅ Good:

```
"The ProjectHub skill enables teams to set up complete project workspaces
in seconds — including pages, databases, and templates — instead of
spending 30 minutes on manual setup."
```

❌ Bad:

```
"The ProjectHub skill is a folder containing YAML frontmatter and Markdown
instructions that calls our MCP server tools."
```

**Highlight the MCP + skills story:**

```
"Our MCP server gives Claude access to your Linear projects. Our skills
teach Claude your team's sprint planning workflow. Together, they enable
AI-powered project management."
```

---

## Patterns and Troubleshooting

These patterns form the enhanced-skill-creator's pattern library. When generating skills, the creator should recognize which pattern(s) best fit the user's use case and apply the corresponding techniques.

### Choosing your approach: Problem-first vs. tool-first

Think of it like Home Depot. You might walk in with a problem — "I need to fix a kitchen cabinet" — and an employee points you to the right tools. Or you might pick out a new drill and ask how to use it for your specific job.

Skills work the same way:

- **Problem-first:** "I need to set up a project workspace" → Your skill orchestrates the right MCP calls in the right sequence. Users describe outcomes; the skill handles the tools.
- **Tool-first:** "I have Notion MCP connected" → Your skill teaches Claude the optimal workflows and best practices. Users have access; the skill provides expertise.

Most skills lean one direction. Knowing which framing fits your use case helps you choose the right pattern below.

### Pattern 1: Sequential workflow orchestration

**Use when:** Your users need multi-step processes in a specific order.

**Example structure:**

```markdown
## Workflow: Onboard New Customer

### Step 1: Create Account
Call MCP tool: `create_customer`
Parameters: name, email, company

### Step 2: Setup Payment
Call MCP tool: `setup_payment_method`
Wait for: payment method verification

### Step 3: Create Subscription
Call MCP tool: `create_subscription`
Parameters: plan_id, customer_id (from Step 1)

### Step 4: Send Welcome Email
Call MCP tool: `send_email`
Template: welcome_email_template
```

**Key techniques:**

- Explicit step ordering
- Dependencies between steps
- Validation at each stage
- Rollback instructions for failures

### Pattern 2: Multi-MCP coordination

**Use when:** Workflows span multiple services.

**Example: Design-to-development handoff**

```markdown
### Phase 1: Design Export (Figma MCP)
1. Export design assets from Figma
2. Generate design specifications
3. Create asset manifest

### Phase 2: Asset Storage (Drive MCP)
1. Create project folder in Drive
2. Upload all assets
3. Generate shareable links

### Phase 3: Task Creation (Linear MCP)
1. Create development tasks
2. Attach asset links to tasks
3. Assign to engineering team

### Phase 4: Notification (Slack MCP)
1. Post handoff summary to #engineering
2. Include asset links and task references
```

**Key techniques:**

- Clear phase separation
- Data passing between MCPs
- Validation before moving to next phase
- Centralized error handling

### Pattern 3: Iterative refinement

**Use when:** Output quality improves with iteration.

**Example: Report generation**

```markdown
## Iterative Report Creation

### Initial Draft
1. Fetch data via MCP
2. Generate first draft report
3. Save to temporary file

### Quality Check
1. Run validation script: `scripts/check_report.py`
2. Identify issues:
   - Missing sections
   - Inconsistent formatting
   - Data validation errors

### Refinement Loop
1. Address each identified issue
2. Regenerate affected sections
3. Re-validate
4. Repeat until quality threshold met

### Finalization
1. Apply final formatting
2. Generate summary
3. Save final version
```

**Key techniques:**

- Explicit quality criteria
- Iterative improvement
- Validation scripts
- Know when to stop iterating

### Pattern 4: Context-aware tool selection

**Use when:** Same outcome, different tools depending on context.

**Example: File storage**

```markdown
## Smart File Storage

### Decision Tree
1. Check file type and size
2. Determine best storage location:
   - Large files (>10MB): Use cloud storage MCP
   - Collaborative docs: Use Notion/Docs MCP
   - Code files: Use GitHub MCP
   - Temporary files: Use local storage

### Execute Storage
Based on decision:
- Call appropriate MCP tool
- Apply service-specific metadata
- Generate access link

### Provide Context to User
Explain why that storage was chosen
```

**Key techniques:**

- Clear decision criteria
- Fallback options
- Transparency about choices

### Pattern 5: Domain-specific intelligence

**Use when:** Your skill adds specialized knowledge beyond tool access.

**Example: Financial compliance**

```markdown
## Payment Processing with Compliance

### Before Processing (Compliance Check)
1. Fetch transaction details via MCP
2. Apply compliance rules:
   - Check sanctions lists
   - Verify jurisdiction allowances
   - Assess risk level
3. Document compliance decision

### Processing
IF compliance passed:
    - Call payment processing MCP tool
    - Apply appropriate fraud checks
    - Process transaction
ELSE:
    - Flag for review
    - Create compliance case

### Audit Trail
- Log all compliance checks
- Record processing decisions
- Generate audit report
```

**Key techniques:**

- Domain expertise embedded in logic
- Compliance before action
- Comprehensive documentation
- Clear governance

### Pattern 6: Conversation-to-skill extraction

**Use when:** You've already built a working workflow interactively and want to capture it.

**Process:**

1. Review the conversation transcript — identify the tools used, the sequence of steps, corrections made
2. Extract the generalizable workflow (not the specific data)
3. Note where you had to redirect Claude — these are the instructions that need to be explicit
4. Identify any scripts Claude wrote ad-hoc that should be bundled
5. Package as a skill, then test with different inputs to verify generalization

**Key techniques:**

- Focus on *why* you made corrections, not just *what* you corrected
- The corrections you made are exactly the instructions that need to be in the skill
- Ad-hoc scripts that Claude wrote are candidates for `scripts/`

### Troubleshooting

#### Skill won't upload

**Error: "Could not find SKILL.md in uploaded folder"**

- **Cause:** File not named exactly `SKILL.md`
- **Solution:**
  - Rename to `SKILL.md` (case-sensitive)
  - Verify with: `ls -la` should show `SKILL.md`

**Error: "Invalid frontmatter"**

- **Cause:** YAML formatting issue
- **Common mistakes:**

```yaml
# Wrong - missing delimiters
name: my-skill
description: Does things

# Wrong - unclosed quotes
name: my-skill
description: "Does things

# Correct
---
name: my-skill
description: Does things
---
```

**Error: "Invalid skill name"**

- **Cause:** Name has spaces or capitals

```yaml
# Wrong
name: My Cool Skill

# Correct
name: my-cool-skill
```

#### Skill doesn't trigger

**Symptom:** Skill never loads automatically

**Fix:** Revise your description field. See [The Description Field](#the-description-field) for good/bad examples.

**Quick checklist:**

- Is it too generic? ("Helps with projects" won't work)
- Does it include trigger phrases users would actually say?
- Does it mention relevant file types if applicable?

**Debugging approach:** Ask Claude: "When would you use the [skill name] skill?" Claude will quote the description back. Adjust based on what's missing.

#### Skill triggers too often

**Symptom:** Skill loads for unrelated queries

**Solutions:**

1. **Add negative triggers**

```yaml
description: Advanced data analysis for CSV files. Use for statistical modeling, regression, clustering. Do NOT use for simple data exploration (use data-viz skill instead).
```

2. **Be more specific**

```yaml
# Too broad
description: Processes documents

# More specific
description: Processes PDF legal documents for contract review
```

3. **Clarify scope**

```yaml
description: PayFlow payment processing for e-commerce. Use specifically for online payment workflows, not for general financial queries.
```

#### MCP connection issues

**Symptom:** Skill loads but MCP calls fail

**Checklist:**

1. **Verify MCP server is connected**
   - Claude.ai: Settings > Extensions > [Your Service]
   - Should show "Connected" status

2. **Check authentication**
   - API keys valid and not expired
   - Proper permissions/scopes granted
   - OAuth tokens refreshed

3. **Test MCP independently**
   - Ask Claude to call MCP directly (without skill)
   - "Use [Service] MCP to fetch my projects"
   - If this fails, issue is MCP not skill

4. **Verify tool names**
   - Skill references correct MCP tool names
   - Check MCP server documentation
   - Tool names are case-sensitive

#### Instructions not followed

**Symptom:** Skill loads but Claude doesn't follow instructions

**Common causes:**

1. **Instructions too verbose**
   - Keep instructions concise
   - Use bullet points and numbered lists
   - Move detailed reference to separate files

2. **Instructions buried**
   - Put critical instructions at the top
   - Use `## Important` or `## Critical` headers
   - Repeat key points if needed

3. **Ambiguous language**

```markdown
# Bad
Make sure to validate things properly

# Good
CRITICAL: Before calling create_project, verify:
- Project name is non-empty
- At least one team member assigned
- Start date is not in the past
```

> **Advanced technique:** For critical validations, consider bundling a script that performs the checks programmatically rather than relying on language instructions. Code is deterministic; language interpretation isn't. See the Office skills for examples of this pattern.

4. **Instruction philosophy misaligned** — If your instructions use heavy-handed MUSTs and rigid structures, Claude may comply literally but miss the intent. Rewrite to explain *why* each step matters — Claude's theory-of-mind reasoning is better engaged by context than by commands.

5. **Model "laziness"** — Add explicit encouragement:

```markdown
## Performance Notes
- Take your time to do this thoroughly
- Quality is more important than speed
- Do not skip validation steps
```

> Note: Adding this to user prompts is more effective than in SKILL.md

#### Large context issues

**Symptom:** Skill seems slow or responses degraded

**Causes:**

- Skill content too large
- Too many skills enabled simultaneously
- All content loaded instead of progressive disclosure

**Solutions:**

1. **Optimize SKILL.md size**
   - Move detailed docs to `references/`
   - Link to references instead of inline
   - Keep SKILL.md under 5,000 words

2. **Reduce enabled skills**
   - Evaluate if you have more than 20–50 skills enabled simultaneously
   - Recommend selective enablement
   - Consider skill "packs" for related capabilities

---

## Resources and References

### External References

**Anthropic official:**
- Best Practices Guide, Skills Documentation, API Reference, MCP Documentation

**Blog posts:**
- Introducing Agent Skills, Equipping Agents for the Real World, Skills Explained, How to Create Skills for Claude, Building Skills for Claude Code, Improving Frontend Design through Skills

**Public skills repository:** `anthropics/skills` — production examples for reference

### Toolchain

The enhanced-skill-creator reuses and extends the existing skill-creator toolchain:

| Tool | Source | Purpose |
|---|---|---|
| `quick_validate.py` | existing skill-creator | Validates SKILL.md frontmatter |
| `package_skill.py` | existing skill-creator | Creates .skill zip files |
| `run_eval.py` | existing skill-creator | Trigger testing via `claude -p` |
| `run_loop.py` | existing skill-creator | Full eval+improve loop with train/test split |
| `improve_description.py` | existing skill-creator | Description improvement from eval failures |
| `aggregate_benchmark.py` | existing skill-creator | Statistical aggregation (mean/stddev/min/max) |
| `generate_report.py` | existing skill-creator | HTML report with auto-refresh |
| `generate_review.py` | existing skill-creator eval-viewer | Interactive HTML review viewer |

### Support

- Community: Claude Developers Discord
- Bug reports: `anthropics/skills/issues`

---

## Appendix A: Quality Checklist

The enhanced-skill-creator validates these gates at each phase. Every generated skill must pass all applicable items before delivery.

### Before you start

- [ ] Identified 2–3 concrete use cases
- [ ] Tools identified (built-in or MCP)
- [ ] Reviewed this guide and example skills
- [ ] Planned folder structure

### During development

- [ ] Folder named in kebab-case
- [ ] SKILL.md file exists (exact spelling)
- [ ] YAML frontmatter has `---` delimiters
- [ ] `name` field: kebab-case, no spaces, no capitals
- [ ] `description` includes WHAT and WHEN
- [ ] No XML tags (`<` `>`) anywhere
- [ ] Instructions are clear and actionable
- [ ] Error handling included
- [ ] Examples provided
- [ ] References clearly linked

### Before upload

- [ ] Tested triggering on obvious tasks
- [ ] Tested triggering on paraphrased requests
- [ ] Verified doesn't trigger on unrelated topics
- [ ] Functional tests pass
- [ ] Tool integration works (if applicable)
- [ ] Compressed as .zip file

### After upload

- [ ] Test in real conversations
- [ ] Monitor for under/over-triggering
- [ ] Collect user feedback
- [ ] Iterate on description and instructions
- [ ] Update version in metadata

---

## Appendix B: YAML Frontmatter Schema

### Required fields

```yaml
---
name: skill-name-in-kebab-case
description: What it does and when to use it. Include specific trigger phrases.
---
```

### All optional fields

```yaml
name: skill-name
description: [required description]
license: MIT                                    # Optional: License for open-source
allowed-tools: "Bash(python:*) Bash(npm:*) WebFetch"  # Optional: Restrict tool access
metadata:                                       # Optional: Custom fields
  author: Company Name
  version: 1.0.0
  mcp-server: server-name
  category: productivity
  tags: [project-management, automation]
  documentation: https://example.com/docs
  support: support@example.com
```

### Security notes

**Allowed:**

- Any standard YAML types (strings, numbers, booleans, lists, objects)
- Custom metadata fields
- Long descriptions (up to 1024 characters)

**Forbidden:**

- XML angle brackets (`<` `>`) — security restriction
- Code execution in YAML (uses safe YAML parsing)
- Skills named with "claude" or "anthropic" prefix (reserved)

---

## Appendix C: Complete Skill Examples

For full, production-ready skills demonstrating the patterns in this guide:

- **Document Skills** — PDF, DOCX, PPTX, XLSX creation
- **Example Skills** — Various workflow patterns
- **Partner Skills Directory** — View skills from various partners such as Asana, Atlassian, Canva, Figma, Sentry, Zapier, and more

These repositories stay up-to-date and include additional examples beyond what's covered here. Clone them, modify them for your use case, and use them as templates.

---

## Appendix D: Environment-Specific Capabilities

The enhanced-skill-creator adapts its workflow based on detected environment. Skills are portable, but each environment has different capabilities that affect development and testing methodology.

### Claude.ai

- **Testing:** Run queries directly, observe behavior manually. No subagents — you test one case at a time.
- **Strengths:** Fast iteration, no setup required, visual output inspection.
- **Limitations:** No parallel test execution, no `claude -p` CLI for description optimization, no blind A/B comparison.
- **Tip:** Focus on qualitative feedback. Present results directly in conversation and ask for inline feedback.

### Claude Code

- **Testing:** Full automation available — subagents for parallel test execution, `claude -p` for trigger testing, scripted evaluation pipelines.
- **Strengths:** Description optimization loop (run_eval + improve_description), benchmark aggregation with statistical analysis, blind comparison.
- **Limitations:** Terminal-based; file outputs need separate inspection for visual content.
- **Tip:** Use the skill-creator skill's full toolchain — trigger eval, blind comparison, and the HTML review viewer.

### API

- **Testing:** Programmatic via `/v1/skills` endpoint and `container.skills` parameter. Build custom evaluation suites.
- **Strengths:** Production-scale testing, CI/CD integration, version management via Claude Console.
- **Limitations:** Requires Code Execution Tool beta. No interactive iteration.
- **Tip:** Best for deployment and monitoring after the skill is already refined in Claude.ai or Claude Code.

### Key differences at a glance

| Capability | Claude.ai | Claude Code | API |
|---|---|---|---|
| Manual testing | ✅ | ✅ | — |
| Parallel test runs | — | ✅ (subagents) | ✅ (custom) |
| Description optimization | — | ✅ (run_loop.py) | ✅ (custom) |
| Blind A/B comparison | — | ✅ | ✅ (custom) |
| Benchmark statistics | — | ✅ (aggregate_benchmark.py) | ✅ (custom) |
| Visual output review | ✅ | ✅ (HTML viewer) | — |
| Org-wide deployment | ✅ (admin) | — | ✅ |

---

## Appendix E: Eval Quality Standards

The enhanced-skill-creator must apply these standards when generating and reviewing test assertions. A passing grade on a weak assertion is worse than useless — it creates false confidence. Watch for:

**Assertions that are trivially satisfied:**

- Checking that a file exists, but not that its content is correct
- Checking that a name appears in output, when a hallucinated document would also pass
- Checking output format but not output substance

**Important outcomes with no assertion:**

- The skill produced a file, but no assertion checks whether the data matches the input
- The workflow completed, but no assertion verifies the intermediate steps were correct
- Error handling was tested, but no assertion checks the error message is helpful

**Good assertions are discriminating:** They pass when the skill genuinely succeeds and fail when it doesn't. Think about what makes an assertion hard to satisfy without actually doing the work correctly.

**For critical validations, prefer code over language:** Write a script that checks programmatically (e.g., parse the output file and verify cell values) rather than asking an evaluator to eyeball it. Scripts are faster, more reliable, and reusable across iterations.
