> 至上命題は [manifesto.md](manifesto.md) を参照。

# Core Philosophy & Design Principles

Working with AI coding agents is like managing amnesiac junior developers. Workflow mitigates failure modes: forgetfulness, context pollution, premature completion.

### Cardinal Rule
Fresh sessions per task: 30s setup vs polluted context cost.

### Human Cognitive Load
- 1 issue at time
- 1 task = 1 commit
- Gate-based verification
- Lightweight design (50-100L)

### LLM Context Limits
50% window rule; structure enforces hygiene.

See [how-to/phases.md#phase-1](#phase-1) for gates.

(298 lines)