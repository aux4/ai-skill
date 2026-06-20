#### Description

The `ai skill` command is the entry point for the aux4 native skill framework. A native skill teaches an AI agent how to use specific aux4 commands. Unlike market-standard `SKILL.md` files (managed by the separate `aux4 ai skills` plural installer), native skills are contributed by aux4 packages that extend the shared `ai:skill` profile.

The framework is LLM-agnostic and ships skills-free — on a clean install `aux4 ai skill list` reports zero skills. It provides:

- **`list`** — discover the native skills installed on the machine.
- **`validate`** — check that a skill conforms to the native skill contract.
- **`export`** — convert a skill to an interop format (`SKILL.md`, `AGENTS.md`, or an MCP tool definition).
- **`init`** — scaffold a new skill in the current directory.

Other packages embed a skill by adding a `<name>` command to the `ai:skill` profile (with a `help.text`) plus an `ai:skill:<name>` profile exposing its domain commands and, optionally, a `prompt` command. There is no `run` command in the contract — running a skill is a runtime concern. The names `list`, `validate`, `export`, and `init` are reserved by the framework.

#### Usage

```bash
aux4 ai skill <command>
```

#### Example

```bash
aux4 ai skill list
```

```text
(no skills installed)
```
