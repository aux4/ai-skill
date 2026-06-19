#### Description

The `run` command executes the example skill against a question by handing the skill's instructions to `aux4 ai agent ask`. The agent loads the instructions, has access to the standard `aux4/ai-agent` tools (including running aux4 commands), and answers the question.

This command requires an LLM provider to be configured for `aux4/ai-agent` (for example via `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`). It is the AI-driven counterpart to `prompt`, which only prints the instructions.

#### Usage

```bash
aux4 ai skill example run <question>
```

question   The question or task to send to the skill (positional argument)

#### Example

```bash
aux4 ai skill example run "How do I list installed aux4 packages?"
```

```text
Run `aux4 aux4 pkger list` to see all installed packages.
```
