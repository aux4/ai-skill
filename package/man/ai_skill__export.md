#### Description

The `export` command converts an installed native skill into an interoperability format so it can be consumed by other agent ecosystems.

The skill's instructions are read via `aux4 ai skill <name> prompt` (which prints the skill's instructions markdown with no AI dependency). A one-line description is derived from the first non-heading line of those instructions. The result is then rendered in one of three formats:

- **`skill`** (default) — a `SKILL.md` document with YAML frontmatter (`name`, `description`) followed by the instructions body, following the Open Agent Skills convention.
- **`agents`** — an `AGENTS.md`-style markdown document.
- **`mcp`** — a JSON MCP tool definition (`name`, `description`, `inputSchema`, `instructions`) wrapping the skill.

By default the export is written to stdout. Pass `--output <file>` to write it to a file instead.

#### Usage

```bash
aux4 ai skill export <name> [--format <skill|agents|mcp>] [--output <file>]
```

name       The name of the skill to export (positional argument)
--format   The output format: `skill`, `agents`, or `mcp` (default: `skill`)
--output   File to write the export to. If omitted, output goes to stdout

#### Example

```bash
aux4 ai skill export deploy --format skill
```

```text
---
name: deploy
description: Deploy applications using aux4 commands.
---

Deploy applications using aux4 commands.
...
```

Write an MCP tool definition to a file:

```bash
aux4 ai skill export deploy --format mcp --output deploy.mcp.json
```

```text
Exported skill 'deploy' to deploy.mcp.json
```
