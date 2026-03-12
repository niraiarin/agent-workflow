# Implementation Boundaries: Choosing the Right Approach

> "The best tools are the ones that work for both humans and machines." — Eric Holmes
>
> When you have a hammer, everything looks like a nail. When you have an LLM, everything looks like a prompt. This document defines when **not** to use Claude — and when each implementation strategy is the right choice.

## Two Orthogonal Axes, Not a Linear Hierarchy

Implementation choices operate on two independent axes:

```
Knowledge Layer          Execution Layer
(what to do, why)        (how to invoke)

 ┌─ Nothing              ┌─ CLI (direct invocation)
 │  (Claude already       │  Shell commands, scripts,
 │   knows enough)        │  existing tools
 │                        │
 ├─ CLAUDE.md / Prompt    ├─ MCP (protocol-mediated)
 │  (lightweight config,  │  Persistent connections,
 │   preferences, rules)  │  service-specific APIs
 │                        │
 ├─ Skill                 └─ None (pure generation)
 │  (domain expertise,        Claude writes output
 │   workflow judgment)        directly
 │
 └─ Agent SDK
    (complex orchestration,
     multi-agent systems)
```

**These axes are orthogonal.** A Skill may orchestrate CLI tools (Skill + CLI), enhance an MCP server with workflow knowledge (Skill + MCP), or generate output using only Claude's built-in capabilities (Skill + no execution layer). The choice on each axis is independent.

This replaces the previous linear model (`CLI → Skill → MCP`), which incorrectly placed orthogonal concerns on a single escalation path.

---

## The Full Spectrum of Options

Before reaching for a Skill or MCP, consider whether a simpler approach suffices:

| Approach | When to use | Example |
|---|---|---|
| **Do nothing** | Claude already knows how | "Run the tests" — Claude knows `pytest` |
| **Prompt engineering** | One-off instructions suffice | "Use our team's commit format: `type(scope): msg`" |
| **CLAUDE.md** | Persistent preferences/rules | Code style, project conventions, banned patterns |
| **Hooks** | Deterministic pre/post actions | Auto-format on save, lint before commit |
| **CLI tool** | Well-defined, deterministic task | `prettier`, `black`, `gh pr list --json` |
| **Skill** | Judgment, workflow, domain expertise | PR review with team conventions, sprint planning |
| **MCP** | External service with no CLI | Service requiring persistent connection, OAuth lifecycle |
| **Agent SDK** | Multi-agent orchestration | Complex pipelines with delegation and parallel execution |

**Default to the simplest approach that works.** Many problems that seem to need a Skill are better solved by a CLAUDE.md entry or a well-structured prompt.

---

## Execution Layer: CLI vs MCP

### When Holmes Is Right

Eric Holmes' "[MCP is Dead. Long Live the CLI](https://ejholmes.github.io/2026/02/28/mcp-is-dead-long-live-the-cli.html)" argues that LLMs naturally use CLIs because they're trained on vast amounts of shell documentation and examples. His core points:

1. **LLMs already know CLIs** — trained on man pages, Stack Overflow, GitHub repos
2. **Same debuggability** — run the same command, see the same output
3. **MCP adds unnecessary abstraction** — when a CLI already exists for the service

These arguments apply directly to the **execution layer**: when choosing *how to invoke* an external service, prefer CLI over MCP if a good CLI exists.

> **Scope of Holmes' argument:** Holmes specifically compares MCP vs CLI as execution interfaces. He does not address Skills, which operate on the knowledge layer. Extending his argument to conclude "Skills are unnecessary" would be a misreading — Skills provide domain expertise and judgment, not an execution interface.

### When CLI Falls Short

CLIs are designed for human consumption. Machine parsing can be fragile:

- **Unstructured output:** Not all CLIs support `--json`. Column-based output (`kubectl get pods`, `docker ps`) has variable widths and changes across versions.
- **Non-determinism:** Network-dependent CLIs, time-sensitive operations, and environment-specific behavior reduce reproducibility.
- **Development cost:** "Near zero cost per invocation" ignores the cost of writing, testing, and maintaining custom CLI scripts.

### When MCP Is Justified

MCP's value is in **persistent, authenticated connections** to external services — not in making API calls (`curl` does that):

- **No CLI equivalent exists** for the service (the primary justification)
- Session management or OAuth token lifecycle that no CLI handles
- Real-time bidirectional communication (push updates, event streams)
- Dynamic, service-specific capability surface that must be exposed to Claude

MCP is **not** justified when:
- A CLI already exists (`gh`, `jira`, `aws`, `kubectl`, etc.)
- The interaction is stateless request/response (`curl` suffices)
- You're wrapping a REST API that doesn't need persistent connections

### Execution Layer Comparison

| Property | CLI | MCP |
|---|---|---|
| Determinism | High (but not guaranteed — network, env, time) | Depends on backing service |
| Output structure | Human-readable; `--json` when available | Structured JSON guaranteed |
| Testability | Unit tests, CI/CD | Integration tests + server |
| Debuggability | Same command, same output | JSON transport logs |
| Composability | Pipes, `jq`, redirects | Protocol-mediated only |
| Auth | Battle-tested (SSO, kubeconfig, `gh auth`) | Protocol-specific schemes |
| Runtime dependency | Shell only | Server process required |
| Initialization | Binary on disk | Flaky — child process lifecycle |

**CLI wins on debuggability and composability. MCP wins on output structure and service coverage.** Choose based on the specific trade-offs relevant to your use case.

---

## Knowledge Layer: Nothing vs CLAUDE.md vs Skill

### The Knowledge Escalation

Unlike the execution layer (where CLI and MCP are alternatives), the knowledge layer *does* have a natural escalation:

```
Nothing → CLAUDE.md → Skill → Agent SDK
simpler                        more complex
```

**Default to nothing.** Escalate only when the simpler option genuinely can't express the needed knowledge.

### When to Use Each

**Nothing (Claude's training data):**
- Standard CLI usage (`gh`, `aws`, `kubectl`, `docker`)
- Common programming patterns and best practices
- Well-known frameworks and libraries

> **Caveat:** Claude's training knowledge is probabilistic, not guaranteed. It may be outdated, lack organization-specific context, or miss recent changes. For *standard* CLI usage of *well-known* tools, this is usually sufficient. For organization-specific CLI wrappers, custom flags, or internal tools, a Skill or CLAUDE.md entry is warranted.

**CLAUDE.md / System prompt:**
- Project conventions (naming, formatting, file structure)
- Team preferences ("always use bun instead of npm")
- Simple rules that don't require judgment ("never commit .env files")

**Skill:**
- Domain expertise that requires judgment (PR review with team conventions)
- Multi-step workflows with adaptive decision-making
- Creative output with specific style/quality standards
- Knowledge too complex or context-dependent for a flat CLAUDE.md

**Agent SDK:**
- Multi-agent orchestration with delegation
- Complex pipelines requiring parallel execution
- Systems needing programmatic control over agent behavior

---

## Skill Categories and CLI Applicability

Skills fall into three categories (per [architecture.md](../skill/architecture.md)), and CLI expectations differ by category:

### Category 1: Document & Asset Creation

**Examples:** `frontend-design`, `docx`, `pptx`, `xlsx`, `canvas-design`, `brand-guidelines`

These skills use Claude's built-in capabilities to generate output. **No CLI component is expected or needed.** The skill's value is in design knowledge, style guides, and quality standards — pure knowledge-layer concerns.

A Category 1 skill with no CLI component is **normal**, not a yellow flag.

### Category 2: Workflow Automation

**Examples:** `skill-creator`, deployment pipelines, code review workflows

These skills orchestrate multi-step processes. **CLI integration is strongly recommended.** Deterministic subtasks within the workflow should be implemented as CLI tools:

- Build scripts in `scripts/` for deterministic subtasks
- Leverage existing CLI tools (`gh`, `jq`, `prettier`, `pandoc`)
- The Skill provides judgment and sequencing; CLI tools provide execution

```
┌─ Skill ──────────────────────────────────────┐
│  Judgment: what to do, in what order, why     │
│                                               │
│  ┌─ CLI layer ─────────────────────────────┐  │
│  │  scripts/validate.py    (self-built)    │  │
│  │  gh pr list             (existing tool) │  │
│  │  jq '.[] | select(..)'  (existing tool) │  │
│  │  scripts/aggregate.py   (self-built)    │  │
│  └─────────────────────────────────────────┘  │
└───────────────────────────────────────────────┘
```

A Category 2 skill with no CLI component **is** a yellow flag — it may mean deterministic work is leaking into the LLM.

### Category 3: MCP Enhancement

**Examples:** `sentry-code-review`, sprint planning with Linear

These skills add workflow knowledge on top of MCP server capabilities. **MCP is expected, not a "last resort."** The skill coordinates MCP calls with domain expertise.

```
┌─────────────────────────────────────────────────┐
│  Skill (workflow knowledge)                      │
│  "Sprint planning best practices"                │
│       │                                          │
│       ▼                                          │
│  MCP (service connection)                        │
│  "Linear API: fetch issues, create tasks"        │
└─────────────────────────────────────────────────┘
```

A Category 3 skill using MCP is the **intended pattern**, not an anti-pattern.

---

## Environment Applicability

CLI-centric guidance applies differently across environments:

| Guidance | Claude Code | API | Claude.ai |
|---|---|---|---|
| CLI-First for Category 2 | **Strongly applies** | **Applies** (with Code Execution) | **Does not apply** (no CLI) |
| Category 1 Skills | Works | Works | **Primary environment** |
| Category 3 (MCP) Skills | Works | Works | Works (with MCP config) |
| CLAUDE.md | Supported | System prompt equivalent | Not applicable |
| Hooks | Supported | Not applicable | Not applicable |

**Claude.ai** is a primary environment for Skill usage — especially Category 1 (document/design creation) and Category 3 (MCP-enhanced workflows). CLI-First guidance does not apply there.

---

## Decision Framework

### Step 1: Do You Need to Build Anything?

| Question | If YES |
|---|---|
| Can Claude already do this without any configuration? | **Do nothing.** Stop here. |
| Can a CLAUDE.md entry or system prompt cover this? | **Write a CLAUDE.md entry.** Stop here. |
| Is this a deterministic pre/post action? | **Use Hooks.** Stop here. |

### Step 2: What Kind of Knowledge Is Needed?

| Question | If YES |
|---|---|
| Does this require domain expertise, judgment, or adaptive workflow? | → **Build a Skill.** Proceed to Step 3. |
| Is this a deterministic, well-defined operation? | → **Build a CLI tool.** Stop here. |

### Step 3: What Execution Layer Does the Skill Need?

| Question | Answer |
|---|---|
| Does the skill generate output using Claude's built-in capabilities? (Category 1) | **Skill only.** No execution layer needed. |
| Does the skill orchestrate deterministic subtasks? (Category 2) | **Skill + CLI.** Extract deterministic steps to `scripts/` or existing CLIs. |
| Does the skill need to connect to an external service? | **Does a CLI exist for the service?** → Skill + CLI. **No CLI exists?** → Skill + MCP. |

### Litmus Tests

Before implementing, ask:

| # | Question | If YES | If NO |
|---|---|---|---|
| 1 | Does a CLI exist **and** does it cover the entire workflow without judgment? | **Use the CLI directly.** | → Q2 |
| 2 | Can I write a complete, deterministic spec for the full task? | **Build a CLI tool.** | → Q3 |
| 3 | Does this require interpreting ambiguous intent or applying judgment? | **Skill.** | → Q4 |
| 4 | Does this require persistent connection to a service with no CLI? | **MCP** (possibly with Skill for workflow). | → Q5 |
| 5 | Is this a multi-step workflow mixing judgment and deterministic steps? | **Skill orchestrating CLI tools.** | → Q6 |
| 6 | Am I building this because it's cool, or because it solves a real problem? | Reconsider. | Reconsider harder. |

> **Note on Q1:** A CLI existing for a domain does not mean the workflow is covered. `gh` exists but doesn't know your team's PR review conventions. `terraform` exists but doesn't know your module structure policy. If the workflow requires judgment, a Skill is warranted even when the CLI exists — the Skill orchestrates the CLI with domain knowledge.

---

## Composability: Where CLI Shines

CLIs compose through pipes, `jq`, `grep`, and redirects. This is powerful and often the only practical approach for deterministic pipelines:

```bash
# Analyze a large Terraform plan: count resources with actual changes
terraform show -json plan.out | jq '[.resource_changes[] | select(.change.actions[0] == "no-op" | not)] | length'
```

**When a workflow is a deterministic pipeline, it should be a shell script, not a Skill.** Skills and MCP compose only through Claude-mediated reasoning, which burns tokens and introduces non-determinism.

However, many real workflows are **not** purely deterministic pipelines — they require judgment at decision points. In these cases, a Skill orchestrating CLI tools provides the best of both worlds.

---

## Anti-Patterns

### 1. "MCP as HTTP client"

```python
# Anti-pattern: MCP server that wraps a simple REST API
class WeatherMCP:
    def get_weather(self, city):
        return requests.get(f"https://api.weather.com/{city}").json()
```

If `curl` can do the same thing, MCP adds complexity without value.

### 2. "MCP when a CLI already exists"

```
# Anti-pattern: Building an MCP server for GitHub
class GitHubMCP:
    def list_prs(self, repo): ...
    def create_issue(self, repo, title, body): ...
```

`gh pr list`, `gh issue create` — already works, already debuggable, already composable.

### 3. "Skill as script wrapper"

```markdown
# Anti-pattern: Skill that just runs a script
## Instructions
Run `python scripts/process.py --input {file} --output {result}`
Return the result to the user.
```

If the Skill's only job is running a script and returning output, it should be a CLI tool directly.

### 4. "Restating standard CLI documentation"

```markdown
# Anti-pattern: Skill that teaches Claude what it already knows
## Instructions
To list pull requests, run `gh pr list`.
To view a PR, run `gh pr view {number}`.
```

Claude already knows standard CLI usage from training data. **However**, documenting *organization-specific* CLI usage is legitimate: custom flags, internal CLI wrappers, team-specific workflows, version-pinned behavior.

### 5. "Everything in one Skill"

```markdown
# Anti-pattern: Monolithic skill
## Instructions
1. Validate the YAML frontmatter (deterministic — should be CLI)
2. Format the markdown (deterministic — should be CLI)
3. Run the test suite (deterministic — should be CLI)
4. Analyze the results and suggest improvements (judgment — correct for Skill)
```

Steps 1–3 should be CLI tools called by the Skill. Only step 4 — the judgment part — belongs in the Skill itself. **(Applies to Category 2 skills; Category 1 skills may legitimately contain only judgment/creative steps.)**

### 6. "CLI for ambiguous input"

```bash
# Anti-pattern: CLI that tries to handle natural language
$ create-skill "something that helps with project management somehow"
```

If the input requires interpretation, forcing it through a CLI creates a bad UX.

---

## The Practical Pain of MCP

Beyond design philosophy, MCP has day-to-day friction that CLIs don't:

- **Initialization is flaky.** MCP servers are child processes that need to start, stay running, and not silently hang.
- **Re-auth never ends.** Multiple MCP tools mean authenticating each one separately.
- **Permissions are all-or-nothing.** You can allowlist MCP tools by name, but can't scope to read-only operations or restrict parameters.

These are real costs that should be weighed against MCP's benefits (structured output, service coverage, persistent connections).

---

## Implications for the Enhanced Skill Creator

### Phase 0: Triage (before any Skill work begins)

Before writing SKILL.md:

1. **Determine the category.** Is this Category 1 (creation), Category 2 (workflow), or Category 3 (MCP enhancement)? This determines CLI expectations.
2. **Search for existing tools.** For Category 2, search for CLI tools covering parts of the workflow. If an existing CLI covers the entire workflow without judgment, the answer is "you don't need a Skill."
3. **Consider simpler alternatives.** Would a CLAUDE.md entry, a Hook, or a system prompt instruction suffice?

### During Skill Creation

| Phase | Gate |
|---|---|
| **Intent capture** | Determine category. For Category 2: "Does a CLI already cover the full workflow without judgment?" |
| **Workflow decomposition** | Category 2: Separate deterministic steps (→ `scripts/` or existing CLI) from judgment steps (→ SKILL.md). Category 1: Focus on quality standards and creative direction. |
| **Skill drafting** | Category 2: SKILL.md orchestrates CLI tools; never put deterministic logic in instructions. Category 1/3: SKILL.md contains knowledge appropriate to the category. |
| **Testing** | CLI components: unit tests, deterministic assertions. Skill components: eval/iteration loop. |

### The Output Standard

**Category 2 Skills must:**
- `scripts/`: Contain CLI tools for deterministic subtasks
- SKILL.md: Reference existing CLI tools; contain only judgment, orchestration, and context
- `compatibility`: List required external CLI tools

**Category 1 Skills must:**
- SKILL.md: Contain design knowledge, style guides, quality standards
- `assets/` (optional): Templates, fonts, reference materials
- No CLI component is expected

**Category 3 Skills must:**
- SKILL.md: Contain workflow knowledge for MCP coordination
- Document required MCP servers and their configuration

---

## References

- Eric Holmes, "[MCP is Dead. Long Live the CLI](https://ejholmes.github.io/2026/02/28/mcp-is-dead-long-live-the-cli.html)" (2026-02-28) — argues for CLI over MCP as an execution interface
- [Skill Architecture — Design Specification](../skill/architecture.md) — defines Skill categories and design principles
