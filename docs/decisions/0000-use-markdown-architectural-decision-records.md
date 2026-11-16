# Use Markdown Architectural Decision Records (MADR)

- Status: accepted
- Date: 2026-10-28

## Context and Problem Statement

We need to record architectural, infrastructure, and technical decisions made in this repository. Decisions should be stored alongside the codebase in version control so that rationale, considered alternatives, and trade-offs remain visible and traceable to all contributors and automated agents.

## Decision Drivers

- Version-controlled alongside code in Git
- Human-readable, structured, and easy to write in Markdown
- Minimal tooling overhead with lightweight templates

## Considered Options

- MADR (Markdown Architectural Decision Records)
- Michael Nygard's Architecture Decision Records format
- Unstructured Wiki / Documentation pages
- Issues / Pull Request discussions

## Decision Outcome

Chosen option: "MADR (Markdown Architectural Decision Records)", because it provides a clean, standardized Markdown template that balances structure and simplicity, can be versioned directly in Git, and is easily reviewed during pull requests.

### Positive Consequences

- Decisions are documented close to code in `docs/decisions/`.
- Clear history and rationale for design and tooling choices.
- Consistent structure across all records using a shared template.

### Negative Consequences

- Authors must maintain discipline in documenting decisions.
