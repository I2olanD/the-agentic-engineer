# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **OpenCode agent/skill/command toolkit** — a collection of markdown-based definitions that extend Claude Code with specialized agents, slash commands, and skills. There is no application code, no build system, and no tests. All artifacts are markdown files with YAML frontmatter.

## Repository Structure

```
agent/          — Subagent definitions (team-based specialists)
command/        — Slash command definitions (user-invocable workflows)
skill/          — Reusable skill definitions (knowledge + methodology modules)
assets/         — Static assets (logo)
opencode.json   — OpenCode configuration (MCP servers, plugins)
```

### Agents (`agent/`)

Team-organized autonomous specialists launched via the Agent tool. Each agent has a single activity focus.

- **the-developer/** — `build-feature`, `optimize-performance`
- **the-architect/** — `review-robustness`, `review-security`, `design-system`, `review-compatibility` + `reference/` checklists
- **the-designer/** — `design-visual`, `design-interaction`, `research-user`
- **the-analyst/** — `research-product`
- **the-tester/** — `test-strategy`
- **the-devops/** — `monitor-production`, `build-platform`

### Commands (`command/`)

User-invocable slash commands that orchestrate multi-phase workflows:

- **/specify** — PRD → SDD → PLAN specification pipeline (delegates to `/specify-requirements`, `/specify-solution`, `/specify-plan`)
- **/implement** — Executes specification plans phase-by-phase, delegating to specialist agents
- **/review** — Multi-perspective code review (security, performance, simplification, quality, testing)
- **/brainstorm** — Design exploration before implementation (probe → approaches → design)
- **/test**, **/debug**, **/refactor**, **/analyze**, **/document**, **/validate**, **/constitution**

### Skills (`skill/`)

Knowledge modules that agents and commands reference for domain expertise. Each skill has a `SKILL.md` plus `reference/`, `templates/`, and `examples/` subdirectories.

Key skills: `project-discovery`, `pattern-detection`, `agentic-patterns`, `writing-skills`, `specify-meta`, `specify-requirements`, `specify-solution`, `specify-plan`, `domain-modeling`, `api-contract-design`, `architecture-selection`, `testing`, `code-quality-review`, `security-assessment`, `performance-analysis`, `platform-operations`, `frontend-patterns`, `technical-writing`, `user-research`, `requirements-elicitation`, `feature-prioritization`

## Key Architectural Patterns

### Agent PICS Layout

All agents follow the Identity → Constraints → Mission → Decision → Activities → Output structure. The meta-agent enforces this pattern.

### Single-Activity Agents

Each agent handles exactly one activity. Multi-capability agents must be split. Agent names are activity-focused (e.g., `build-feature`), never framework-specific (e.g., `react-expert`).

### Frontmatter Convention

All markdown definitions use YAML frontmatter with:

- `description` — Single sentence describing the artifact
- `mode` — `primary` or `subagent` (agents only)
- `model` — Model specification (agents only)
- `skills` — Comma-separated skill references
- `allowed-tools` — Tool access restrictions
- `argument-hint` — Usage hint for commands

### Specification Workflow

Specs live in `.start/specs/[NNN]-[name]/` with auto-incrementing IDs:

```
README.md         — Decisions and progress tracking
requirements.md   — PRD (what and why)
solution.md       — SDD (how)
plan/             — README.md manifest + phase-N.md files
```

Phase status is tracked in frontmatter (`pending` → `in_progress` → `completed`) and plan/README.md checkboxes.

### Orchestration Pattern

Commands like `/implement` and `/review` are orchestrators — they never implement directly but delegate all work to subagents. `/implement` loads one phase at a time and runs `/validate` at phase boundaries.

## Editing Guidelines

- When creating new agents, check for duplicates against existing agents first
- New agents must follow the PICS layout and pass the meta-agent validation checklist
- Skills must have a `SKILL.md` with proper frontmatter (name, description, license, compatibility, metadata)
- Commands must include `argument-hint` and `allowed-tools` in frontmatter
- All definitions use a pseudo-code block style (e.g., `BuildFeature { Focus { ... } Approach { ... } }`)
- Reference materials go in `reference/` subdirectories; templates in `templates/`; examples in `examples/`
