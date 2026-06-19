#### Description

The `prompt` command prints the instructions for the example skill. It simply `cat`s the skill's instructions markdown and has no AI or network dependency, which makes it deterministic and safe to call programmatically.

Every native skill exposes a `prompt` command following this convention. The framework's `export` command relies on it to read a skill's instructions, and agents use it to load a skill's guidance before acting.

#### Usage

```bash
aux4 ai skill example prompt
```

#### Example

```bash
aux4 ai skill example prompt
```

```text
Discover and run aux4 commands to accomplish a user's task.

You are an aux4 agent skill that knows how to explore the locally installed
aux4 CLI and run the right commands to answer a question or complete a task.
...
```
