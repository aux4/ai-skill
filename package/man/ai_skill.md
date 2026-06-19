#### Description

The `ai skill` command is the entry point for the aux4 native skill framework. A native skill teaches an AI agent how to use specific aux4 commands. Unlike market-standard `SKILL.md` files (managed by the separate `aux4 ai skills` plural installer), native skills are contributed by aux4 packages that extend the shared `ai:skill` profile.

The framework provides:

- **`list`** — discover the native skills installed on the machine.
- **`export`** — convert a skill to an interop format (`SKILL.md`, `AGENTS.md`, or an MCP tool definition).
- **`init`** — scaffold a new skill in the current directory.
- **`example`** — a reference skill bundled with this package that demonstrates the contribution contract.

Other packages embed a skill by adding a `<name>` command to the `ai:skill` profile and an `ai:skill:<name>` profile exposing `prompt` (and optionally `run`). The names `list`, `export`, and `init` are reserved by the framework.

#### Usage

```bash
aux4 ai skill <command>
```

#### Example

```bash
aux4 ai skill list
```

```text
example  -  Example skill: how to author and use aux4 skills
```
