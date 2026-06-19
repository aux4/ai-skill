# aux4/ai-skill

Native skill framework for aux4 — author, discover, validate, and export agent skills.

A **native skill** teaches an AI agent how to use specific aux4 capabilities. Native skills are contributed by aux4 packages that extend the shared `ai:skill` profile. This package is a pure, LLM-agnostic **framework**: it owns the contract and provides discovery (`list`), validation (`validate`), scaffolding (`init`), and interop export (`export`). It ships **skills-free** — on a clean install `aux4 ai skill list` reports zero skills. Skills come from other packages.

> **Native vs. market skills:** This package (`aux4 ai skill`, singular) is the aux4-native skill framework. It is distinct from `aux4 ai skills` (plural), which installs market-standard `SKILL.md` files from the open skills ecosystem. The two are complementary and intentionally kept separate; `export` bridges native skills into `SKILL.md` / `AGENTS.md` / MCP.

## Installation

```bash
aux4 aux4 pkger install aux4/ai-skill
```

## Quick Start

```bash
# List the native skills installed on your machine (empty on a clean install)
aux4 ai skill list

# Scaffold a new skill in the current directory
aux4 ai skill init deploy

# Check a skill conforms to the native skill contract
aux4 ai skill validate deploy

# Export a skill to a SKILL.md document
aux4 ai skill export deploy --format skill
```

## Commands

| Command | Description |
|---------|-------------|
| `aux4 ai skill list` | List installed native skills with descriptions |
| `aux4 ai skill validate` | Check a skill conforms to the native skill contract |
| `aux4 ai skill export` | Export a skill to an interop format (`SKILL.md`, `AGENTS.md`, or MCP) |
| `aux4 ai skill init` | Scaffold a new native skill in the current directory |

### aux4 ai skill list

Discovers native skills by parsing `aux4 ai skill --help` and printing a catalog of skill names and descriptions. The reserved framework commands (`list`, `validate`, `export`, `init`) are excluded. Returns no output until packages contribute skills.

```bash
aux4 ai skill list
```

```text
deploy  -  Deploy applications using aux4 commands
```

### aux4 ai skill validate

Checks that an installed skill conforms to the native skill contract: it must be registered under the `ai:skill` profile, have a non-empty `help.text`, and (recommended) expose at least one command. `prompt` is optional; `run` is not part of the contract.

```bash
aux4 ai skill validate <name>
```

```text
Validating native skill: deploy

  [PASS] registered under the ai:skill profile
  [PASS] has help.text: Deploy applications using aux4 commands
  [PASS] exposes 1 command(s) in the ai:skill:deploy profile

Skill 'deploy' conforms to the native skill contract.
```

The command exits non-zero when the skill does not conform.

### aux4 ai skill export

Exports an installed skill to an interoperability format. The skill's instructions are read via `aux4 ai skill <name> prompt`. By default the export goes to stdout; pass `--output <file>` to write a file.

```bash
aux4 ai skill export <name> [--format <skill|agents|mcp>] [--output <file>]
```

- `skill` (default) — a `SKILL.md` document (YAML frontmatter + instructions body), following the Open Agent Skills convention.
- `agents` — an `AGENTS.md`-style markdown document.
- `mcp` — a JSON MCP tool definition wrapping the skill.

```bash
aux4 ai skill export deploy --format skill
aux4 ai skill export deploy --format agents --output AGENTS.md
aux4 ai skill export deploy --format mcp --output deploy.mcp.json
```

### aux4 ai skill init

Scaffolds a new native skill. It creates `instructions/<name>.md` and a `man/ai_skill_<name>__prompt.md` stub (only if they do not already exist) and prints the `.aux4` profile snippet to embed the skill. The snippet contains a routing command with `help.text` and an optional `prompt` command — and no `run`.

```bash
aux4 ai skill init <name>
```

```bash
aux4 ai skill init deploy
```

## The Native Skill Contract

A native skill is just an aux4 package that contributes to the shared `ai:skill` profile. The framework owns this contract; skills conform to it.

### Disclosure ladder

Skills are designed for **progressive disclosure** so agents stay lean — they read only what they need, when they need it:

1. **`help.text`** (REQUIRED) — the `--help` discovery layer: a sharp one-liner for the skill plus one per command. Always loaded, cheap. This is what `aux4 ai skill list` and `aux4 ai skill --help` surface.
2. **`man/<profile>__<command>.md`** (recommended) — the richer "is this a good fit?" middle tier. An agent reads it on demand to assess a candidate skill without loading prose.
3. **`prompt`** (OPTIONAL) — deep when/how/workflow/rules guidance for non-trivial skills. Loaded only when a complex skill is actually engaged.
4. **`--help`** — command signatures and parameters, provided for free by aux4.

### Contract

- Skills live under scope `agent`, named `skill-<name>` (e.g. `agent/skill-memory`).
- Skills depend on **`aux4/ai-skill` only** — never on `aux4/ai-agent` (skills are LLM-agnostic; the LLM belongs to the runtime).
- Skills contribute a `<name>` command to the `ai:skill` profile and an `ai:skill:<name>` profile.
- Skills MUST have a sharp `help.text` (skill one-liner + one per command) — the required discovery layer.
- Skills MAY expose domain commands (their actual capabilities), man pages (fit info), and an optional `prompt` command (deep guidance).
- Skills have **no `run` command.** Running a skill is a runtime concern (`aux4 ai agent ask --instructions <prompt>`), not part of the skill. Baking `run` into a skill would invert the dependency (skill → ai-agent), so it is dropped from the contract.
- The names `list`, `validate`, `export`, and `init` are **reserved** by the framework and must not be used as skill names.

### Two skill flavors

- **Command skill** (deterministic, e.g. `memory`): `help.text` + domain commands (+ optional `prompt`). The agent calls the commands directly with its own tools. Leanest — zero instruction injection.
- **Instruction skill** (LLM-task guidance, e.g. `research`, `planner`): `help.text` + `prompt`. The agent loads the prompt on demand and follows it with its own tools.

### Embedding a skill

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
            "text": "Show the deploy skill guidance (optional)"
          }
        }
      ]
    }
  ]
}
```

Add `"aux4/ai-skill"` to your package `dependencies` (so the `ai:skill` profile exists for discovery). Add your own domain commands to the `ai:skill:deploy` profile. Once installed, the skill appears in `aux4 ai skill list`, validates with `aux4 ai skill validate deploy`, and exports with `aux4 ai skill export deploy`.

## Dependencies

This framework has no skill dependencies — it is LLM-agnostic and ships skills-free.

## License

This package is licensed under the Apache-2.0 License.

See [LICENSE](./LICENSE) for details.
