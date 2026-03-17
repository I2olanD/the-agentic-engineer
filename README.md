<h1 align="center">The Agentic Engineer</h1>

<p align="center">
  A comprehensive collection of agents, commands, and skills that extend <a href="https://opencode.ai">OpenCode</a> into a full software engineering team.
</p>

<p align="center">
  <em>Ported from <a href="https://github.com/rsmdt/the-startup">the-startup</a></em>
</p>

---

## What Is This?

This toolkit transforms [OpenCode](https://opencode.ai) from a single AI coding assistant into a coordinated team of specialists. It provides **13 autonomous agents**, **13 slash commands**, and **21 reusable skills** — all defined as markdown files with YAML frontmatter. No application code, no build system, no runtime dependencies.

## Quick Start

```bash
git clone <repo-url> && cd the-agentic-engineer
./install.sh
```

The installer copies agents, commands, skills, and configuration to `~/.config/opencode/`. Supports `--dry-run`, `--uninstall`, and `--path <dir>`.

```
/specify     Build a user authentication system with OAuth2
/implement   001 autonomous
/review      staged
/sweep       packages/api
/audit       src/
```

## Architecture

```
User ──→ /command ──→ orchestrates ──→ agents ──→ produce output
                          ↑                          ↑
                        skills ←─── reference ───── skills
```

**Commands** are user-facing workflows. **Agents** are autonomous specialists. **Skills** are shared knowledge modules.

```
agent/          Team-organized specialist agents
command/        Slash commands (user-invocable workflows)
skill/          Knowledge modules (reference material for agents)
opencode.json   OpenCode configuration (MCP servers, plugins)
```

## Commands

| Command         | Description                                                                                          |
| --------------- | ---------------------------------------------------------------------------------------------------- |
| `/specify`      | Create a full specification (PRD → SDD → Plan) from a brief description                              |
| `/implement`    | Execute a spec plan phase-by-phase via specialist agents. Supports `autonomous` mode                 |
| `/review`       | Multi-perspective code review (security, performance, dead code, simplification, tests)              |
| `/brainstorm`   | Explore intent, requirements, and design before implementation                                       |
| `/sweep`        | Dead code analysis with proof-before-removal verification                                            |
| `/audit`        | Parallel multi-agent codebase health check (type safety, dead code, coverage, security, performance) |
| `/test`         | Run and verify the test suite, enforce strict code ownership                                         |
| `/debug`        | Diagnose and resolve bugs through root cause analysis                                                |
| `/refactor`     | Simplify and clean up code without changing business logic                                           |
| `/analyze`      | Discover business rules, technical patterns, and system interfaces                                   |
| `/document`     | Generate and maintain documentation for code, APIs, and components                                   |
| `/validate`     | Validate specifications, implementations, and constitution compliance                                |
| `/constitution` | Create or update project governance rules                                                            |

The core specification pipeline: `/specify` produces `requirements.md` → `solution.md` → `plan/` phases, stored in `.engineer/specs/[NNN]-[name]/`. `/implement` executes phases sequentially with `/validate` at each boundary.

## Agents

Each agent handles exactly one activity. Organized by team:

| Team      | Agent                  | Focus                                                                   |
| --------- | ---------------------- | ----------------------------------------------------------------------- |
| Developer | `build-feature`        | Build features with autonomous TDD loop, validation, and error handling |
| Developer | `optimize-performance` | Profile and optimize across frontend, backend, and database layers      |
| Architect | `review-robustness`    | Complexity and concurrency safety review                                |
| Architect | `review-security`      | Vulnerabilities, supply chain risks, and compliance                     |
| Architect | `review-compatibility` | Breaking changes and migration paths                                    |
| Architect | `design-system`        | Service boundaries, scalability, and deployment architecture            |
| Designer  | `design-visual`        | Visual foundations, tokens, and WCAG accessibility                      |
| Designer  | `design-interaction`   | Information architecture, navigation, and user flows                    |
| Designer  | `research-user`        | Behavioral interviews, personas, and pattern synthesis                  |
| Analyst   | `research-product`     | Market evidence and requirement clarification                           |
| Tester    | `test-strategy`        | Functional quality and performance resilience testing                   |
| DevOps    | `build-platform`       | Containers, IaC, and CI/CD automation                                   |
| DevOps    | `monitor-production`   | Metrics, alerting, SLIs, SLOs, and observability                        |

## Skills

21 knowledge modules across specification, architecture, quality, discovery, and operations. Each has a `SKILL.md` plus `reference/`, `templates/`, and `examples/` subdirectories.

<details>
<summary>Full skill list</summary>

**Specification**: `specify-meta`, `specify-requirements`, `specify-solution`, `specify-plan`

**Architecture & Design**: `architecture-selection`, `api-contract-design`, `domain-modeling`, `frontend-patterns`, `agentic-patterns`

**Quality & Security**: `code-quality-review`, `security-assessment`, `testing`, `performance-analysis`

**Discovery & Research**: `project-discovery`, `pattern-detection`, `user-research`, `requirements-elicitation`, `feature-prioritization`

**Operations & Documentation**: `platform-operations`, `technical-writing`, `writing-skills`

</details>

## Design Principles

- **Single-activity agents** — each agent does one thing well, no multi-capability agents
- **PICS layout** — agents follow Identity → Constraints → Mission → Output structure
- **Orchestration over implementation** — commands delegate to agents, never write code directly
- **Skills as shared knowledge** — reusable modules referenced by multiple agents and commands
- **Markdown-native** — no compilation, no build step, portable across LLM providers

## License

MIT
