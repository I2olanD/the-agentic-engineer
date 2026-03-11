<h1 align="center">The Agentic Engineering Toolkit</h1>

<p align="center">
  A comprehensive collection of agents, commands, and skills that extend <a href="https://opencode.ai">OpenCode</a> into a full software engineering team.
</p>

---

## What Is This?

This toolkit transforms [OpenCode](https://opencode.ai) from a single AI coding assistant into a coordinated team of specialists. It provides **13 autonomous agents**, **11 slash commands**, and **21 reusable skills** — all defined as markdown files with YAML frontmatter. No application code, no build system, no runtime dependencies.

Drop this into your OpenCode configuration and gain access to structured workflows for specification, implementation, review, testing, debugging, and more — all orchestrated through OpenCode's agent system. Works with any LLM provider that OpenCode supports.

## Quick Start

### Install

```bash
# Clone into your OpenCode config directory
git clone <repo-url> ~/.config/opencode/agentic-engineering
```

Or add it to your project directly:

```bash
git clone <repo-url> .opencode/agentic-engineering
```

### Configure

The included `opencode.json` provides the base configuration with MCP servers:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["cc-safety-net"],
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "@playwright/mcp@latest"]
    },
    "deepwiki": {
      "type": "remote",
      "url": "https://mcp.deepwiki.com/mcp",
      "enabled": true
    }
  }
}
```

### Use

Invoke slash commands directly in OpenCode:

```
/specify     Build a user authentication system with OAuth2
/implement   001
/review      staged
/brainstorm  What's the best way to handle real-time notifications?
```

Agents are invoked automatically when tasks match their specialization, or triggered explicitly through orchestrating commands like `/implement` and `/review`.

## Architecture

```
the-agentic-engineer/
├── agent/              Autonomous specialist agents (team-organized)
│   ├── the-developer/      Build features, optimize performance
│   ├── the-architect/      Security, robustness, compatibility, system design
│   ├── the-designer/       Visual design, interaction design, user research
│   ├── the-analyst/        Product research and prioritization
│   ├── the-tester/         Test strategy and execution
│   └── the-devops/         Platform builds, production monitoring
├── command/            Slash commands (user-invocable workflows)
├── skill/              Knowledge modules (reference material for agents)
├── assets/             Static assets
└── opencode.json       OpenCode configuration (MCP servers, plugins)
```

### How It Fits Together

```
User ──→ /command ──→ orchestrates ──→ agents ──→ produce output
                          ↑                          ↑
                        skills ←─── reference ───── skills
```

**Commands** are user-facing entry points that orchestrate workflows. **Agents** are autonomous specialists that do the actual work. **Skills** are knowledge modules that both commands and agents draw on for domain expertise.

## Commands

Slash commands are the primary interface. Use them directly in OpenCode.

| Command         | Description                                                                            |
| --------------- | -------------------------------------------------------------------------------------- |
| `/specify`      | Create a full specification (PRD → SDD → Plan) from a brief description                |
| `/implement`    | Execute a specification plan phase-by-phase, delegating to specialist agents           |
| `/review`       | Multi-perspective code review (security, performance, patterns, simplification, tests) |
| `/brainstorm`   | Explore intent, requirements, and design before implementation                         |
| `/test`         | Run and verify the test suite, enforce strict code ownership                           |
| `/debug`        | Systematically diagnose and resolve bugs through root cause analysis                   |
| `/refactor`     | Simplify and clean up code without changing business logic                             |
| `/analyze`      | Discover business rules, technical patterns, and system interfaces                     |
| `/document`     | Generate and maintain documentation for code, APIs, and components                     |
| `/validate`     | Validate specifications, implementations, and constitution compliance                  |
| `/constitution` | Create or update project governance rules through discovery                            |

### The Specification Pipeline

The core workflow follows a structured pipeline:

```
/specify  →  requirements.md (PRD)  →  solution.md (SDD)  →  plan/ (phases)
/implement  →  executes phases sequentially  →  /validate at each boundary
```

Specifications are stored in `.start/specs/[NNN]-[name]/` with auto-incrementing IDs and tracked status (`pending` → `in_progress` → `completed`).

## Agents

Agents are autonomous specialists organized into teams. Each agent handles exactly one activity — no multi-capability agents.

### The Developer

| Agent                  | Description                                                                                            |
| ---------------------- | ------------------------------------------------------------------------------------------------------ |
| `build-feature`        | Build features across any technology layer with architecture, validation, error handling, and tests    |
| `optimize-performance` | Systematically optimize performance across frontend, backend, and database layers based on measurement |

### The Architect

| Agent                  | Description                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------- |
| `review-robustness`    | Review code for robustness risks from unnecessary complexity and unsafe concurrency patterns      |
| `review-security`      | Review code and dependencies for security vulnerabilities, supply chain risks, and compliance     |
| `review-compatibility` | Review code for breaking changes and compatibility issues with clear migration paths              |
| `design-system`        | Design system architecture with service boundaries, scalability patterns, and deployment strategy |

### The Designer

| Agent                | Description                                                                                      |
| -------------------- | ------------------------------------------------------------------------------------------------ |
| `design-visual`      | Establish visual design foundations and accessibility standards with tokens and WCAG conformance |
| `design-interaction` | Design information architecture, navigation, and user flows                                      |
| `research-user`      | Conduct user research through behavioral interviews, personas, and pattern synthesis             |

### The Analyst

| Agent              | Description                                                                           |
| ------------------ | ------------------------------------------------------------------------------------- |
| `research-product` | Research product direction by combining market evidence and requirement clarification |

### The Tester

| Agent           | Description                                                                              |
| --------------- | ---------------------------------------------------------------------------------------- |
| `test-strategy` | Design and execute testing strategy across functional quality and performance resilience |

### The DevOps

| Agent                | Description                                                                           |
| -------------------- | ------------------------------------------------------------------------------------- |
| `build-platform`     | Build delivery platforms end-to-end with containers, IaC, and CI/CD automation        |
| `monitor-production` | Implement production monitoring with metrics, alerting, SLIs, SLOs, and observability |

## Skills

Skills are knowledge modules that agents and commands reference for domain expertise. Each has a `SKILL.md` plus `reference/`, `templates/`, and `examples/` subdirectories.

<details>
<summary><strong>Specification Skills</strong></summary>

| Skill                  | Description                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------- |
| `specify-meta`         | Scaffold and manage specification directories with auto-incrementing IDs and phase tracking |
| `specify-requirements` | Create and validate product requirements documents (PRD)                                    |
| `specify-solution`     | Create and validate solution design documents (SDD)                                         |
| `specify-plan`         | Create and validate implementation plans with TDD phase structure                           |

</details>

<details>
<summary><strong>Architecture & Design Skills</strong></summary>

| Skill                    | Description                                                                                       |
| ------------------------ | ------------------------------------------------------------------------------------------------- |
| `architecture-selection` | System architecture patterns (monolith, microservices, event-driven, serverless) with C4 modeling |
| `api-contract-design`    | REST/GraphQL API design, OpenAPI specs, versioning, and authentication patterns                   |
| `domain-modeling`        | Business entities, invariants, schema design, aggregate boundaries, and evolution strategy        |
| `frontend-patterns`      | Component libraries with shadcn/ui and Tailwind CSS                                               |
| `agentic-patterns`       | AI agent development with LangChain, Vercel AI SDK, and assistant-ui                              |

</details>

<details>
<summary><strong>Quality & Security Skills</strong></summary>

| Skill                  | Description                                                                                   |
| ---------------------- | --------------------------------------------------------------------------------------------- |
| `code-quality-review`  | Correctness, design, readability, security, performance, and testability review               |
| `security-assessment`  | Vulnerability review, threat modeling, OWASP patterns, and secure coding                      |
| `testing`              | Test design principles, layer-specific mocking, debugging failures, and flaky test management |
| `performance-analysis` | Profiling, bottleneck identification, and optimization guidance                               |

</details>

<details>
<summary><strong>Discovery & Research Skills</strong></summary>

| Skill                      | Description                                                                               |
| -------------------------- | ----------------------------------------------------------------------------------------- |
| `project-discovery`        | Codebase discovery across structure, tech-stack detection, and documentation extraction   |
| `pattern-detection`        | Identify naming conventions, architectural patterns, and testing patterns for consistency |
| `user-research`            | Interviews, usability testing, personas, journey mapping, and insight synthesis           |
| `requirements-elicitation` | Requirement gathering, stakeholder analysis, and specification validation                 |
| `feature-prioritization`   | RICE, MoSCoW, Kano, and value-effort frameworks with scoring methodologies                |

</details>

<details>
<summary><strong>Operations & Documentation Skills</strong></summary>

| Skill                 | Description                                                                            |
| --------------------- | -------------------------------------------------------------------------------------- |
| `platform-operations` | CI/CD pipelines, deployment strategies, observability, SLI/SLOs, and rollback controls |
| `technical-writing`   | ADRs, system docs, API documentation, and operational runbooks                         |
| `writing-skills`      | Skill authoring, auditing, and deployment verification                                 |

</details>

## Design Principles

### Single-Activity Agents

Each agent does one thing well. No Swiss-army-knife agents. This keeps agents focused, testable, and composable.

### PICS Layout

All agents follow a consistent structure: **P**ersonality/Identity → **I**nput constraints → **C**ommands/Mission → **S**cope/Output. The meta-agent enforces this pattern.

### Orchestration Over Implementation

Commands like `/implement` and `/review` never write code directly. They orchestrate specialist agents and validate at phase boundaries.

### Skills as Shared Knowledge

Skills are reusable knowledge modules, not agents. Multiple agents can reference the same skill, ensuring consistent domain expertise across the team.

### Markdown-Native

Everything is defined in markdown with YAML frontmatter. No compilation, no build step, no runtime dependencies. Human-readable, version-controllable, and portable across any LLM provider that OpenCode supports.

## Extending the Toolkit

### Adding a New Agent

1. Check for duplicates against existing agents
2. Create `agent/<team>/<activity-name>.md` with YAML frontmatter
3. Follow the PICS layout structure
4. Assign a single activity focus
5. Reference relevant skills in frontmatter

### Adding a New Skill

1. Create `skill/<skill-name>/SKILL.md` with frontmatter (`name`, `description`, `license`, `compatibility: opencode`)
2. Add `reference/` for domain knowledge, `templates/` for reusable templates, `examples/` for samples
3. Reference from agents that need the knowledge

### Adding a New Command

1. Create `command/<command-name>.md` with `description`, `argument-hint`, and `allowed-tools` in frontmatter
2. Define the orchestration workflow
3. Delegate actual work to agents — commands should orchestrate, not implement

## Compatibility

Built for [OpenCode](https://opencode.ai). All skills declare `compatibility: opencode` in their frontmatter. The toolkit leverages OpenCode's agent system, slash commands, skill loading, and MCP server integration.

## License

MIT
