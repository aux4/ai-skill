#### Description

The `example` command is the reference skill bundled with the native skill framework. It demonstrates the contribution contract that every native skill follows: a `<name>` command in the `ai:skill` profile that routes to an `ai:skill:<name>` profile exposing `prompt` and `run`.

The skill itself teaches an agent how to discover and run aux4 commands using `--help`, positional arguments, and `--config`. Use it as a working template when authoring your own skills.

#### Usage

```bash
aux4 ai skill example <command>
```

#### Example

Show the skill's instructions:

```bash
aux4 ai skill example prompt
```

Run the skill against a question (requires an LLM provider configured for `aux4/ai-agent`):

```bash
aux4 ai skill example run "How do I list installed packages?"
```
