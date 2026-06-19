# aux4/ai-skill

Native skill framework for aux4 — author, discover, run, and export agent skills.

A **native skill** teaches an AI agent how to use specific aux4 commands. Native skills are contributed by aux4 packages that extend the shared `ai:skill` profile. The framework provides discovery (`list`), interop export (`export`), and scaffolding (`init`), plus a bundled `example` skill that demonstrates the contribution contract end to end.

> **Native vs. market skills:** This package (`aux4 ai skill`, singular) is the aux4-native skill framework. It is distinct from `aux4 ai skills` (plural), which installs market-standard `SKILL.md` files from the open skills ecosystem. The two are complementary and intentionally kept separate.

## Installation

```bash
aux4 aux4 pkger install aux4/ai-skill
```

## Quick Start

```bash
# List the native skills installed on your machine
aux4 ai skill list

# Read the bundled example skill's instructions
aux4 ai skill example prompt

# Export a skill to a SKILL.md document
aux4 ai skill export example --format skill

# Scaffold a new skill in the current directory
aux4 ai skill init deploy
```

## Commands

| Command | Description |
|---------|-------------|
| `aux4 ai skill list` | List installed native skills with descriptions |
| `aux4 ai skill export` | Export a skill to an interop format (`SKILL.md`, `AGENTS.md`, or MCP) |
| `aux4 ai skill init` | Scaffold a new native skill in the current directory |
| `aux4 ai skill example prompt` | Show the bundled example skill's instructions |
| `aux4 ai skill example run` | Run the example skill against a question (requires an LLM) |

### aux4 ai skill list

Discovers native skills by parsing `aux4 ai skill --help` and printing a catalog of skill names and descriptions. The reserved framework commands (`list`, `export`, `init`) are excluded.

```bash
aux4 ai skill list
```

```text
example  -  Example skill: how to author and use aux4 skills
```

### aux4 ai skill export

Exports an installed skill to an interoperability format. The skill's instructions are read via `aux4 ai skill <name> prompt`. By default the export goes to stdout; pass `--output <file>` to write a file.

```bash
aux4 ai skill export <name> [--format <skill|agents|mcp>] [--output <file>]
```

- `skill` (default) — a `SKILL.md` document (YAML frontmatter + instructions body), following the Open Agent Skills convention.
- `agents` — an `AGENTS.md`-style markdown document.
- `mcp` — a JSON MCP tool definition wrapping the skill.

```bash
aux4 ai skill export example --format skill
aux4 ai skill export example --format agents --output AGENTS.md
aux4 ai skill export example --format mcp --output example.mcp.json
```

### aux4 ai skill init

Scaffolds a new native skill. It creates `instructions/<name>.md` (only if it does not already exist) and prints the `.aux4` profile snippet to embed the skill.

```bash
aux4 ai skill init <name>
```

```bash
aux4 ai skill init deploy
```

### aux4 ai skill example

The bundled reference skill demonstrating the contribution contract. It teaches an agent how to discover and run aux4 commands.

```bash
aux4 ai skill example prompt
aux4 ai skill example run "How do I list installed packages?"
```

`prompt` only prints the instructions (no AI dependency). `run` hands the instructions to `aux4 ai agent ask` and requires an LLM provider to be configured for `aux4/ai-agent`.

## Embedding a Skill (Contribution Contract)

Any aux4 package can contribute a native skill. The contract is:

1. Add a `<name>` command to the `ai:skill` profile that routes to an `ai:skill:<name>` profile.
2. In the `ai:skill:<name>` profile, expose:
   - `prompt` — `cat`s the skill's instructions markdown. **No AI dependency** — this is what `list` and `export` rely on, so it must always work offline.
   - `run` (optional) — calls `aux4 ai agent ask` with the instructions to execute the skill.

The names `list`, `export`, and `init` are **reserved** by the framework and must not be used as skill names.

Run `aux4 ai skill init <name>` to generate the snippet, or copy this template into your package `.aux4`:

```json
{
  "profiles": [
    {
      "name": "ai:skill",
      "commands": [
        {
          "name": "deploy",
          "execute": [
            "profile:ai:skill:deploy"
          ],
          "help": {
            "text": "Deploy applications using aux4 commands"
          }
        }
      ]
    },
    {
      "name": "ai:skill:deploy",
      "commands": [
        {
          "name": "prompt",
          "execute": [
            "cat ${packageDir}/instructions/deploy.md"
          ],
          "help": {
            "text": "Show the deploy skill instructions"
          }
        },
        {
          "name": "run",
          "execute": [
            "aux4 ai agent ask --instructions ${packageDir}/instructions/deploy.md param(question)"
          ],
          "help": {
            "text": "Run the deploy skill with a question",
            "variables": [
              {
                "name": "question",
                "text": "The question to ask the deploy skill",
                "arg": true
              }
            ]
          }
        }
      ]
    }
  ]
}
```

Add `"aux4/ai-skill"` (and `"aux4/ai-agent"` if you use `run`) to your package `dependencies`. Once installed, the skill appears in `aux4 ai skill list` and can be exported with `aux4 ai skill export deploy`.

## Dependencies

- `aux4/ai-agent` — LLM agent framework used by `run` commands.

## License

This package is licensed under the Apache-2.0 License.

See [LICENSE](./LICENSE) for details.
