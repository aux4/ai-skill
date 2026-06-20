#### Description

The `init` command scaffolds a new native skill in the current working directory.

It creates (only when they do not already exist, so it never overwrites your work):

- `instructions/prompt.md` — a starter prompt template for the skill's optional deep guidance.
- `man/ai_skill_<name>__prompt.md` — a man page stub for the optional `prompt` command.

It then prints the `.aux4` profile snippet to embed the skill, conforming to the native skill contract:

- a `<name>` routing command in the `ai:skill` profile, with a `help.text` (the REQUIRED discovery layer);
- an `ai:skill:<name>` profile exposing an **optional** `prompt` command (deep when/how/workflow/rules guidance, loaded on demand) — keep it only for non-trivial skills.

The snippet contains **no `run` command**: running a skill is a runtime concern (`aux4 ai agent ask --instructions <prompt>`), not part of the skill contract. Add your own domain commands to the `ai:skill:<name>` profile to give the skill its capabilities.

#### Usage

```bash
aux4 ai skill init <name>
```

name   The name of the skill to scaffold (positional argument)

#### Example

```bash
aux4 ai skill init deploy
```

```text
Created instructions/prompt.md
Created man/ai_skill_deploy__prompt.md

Add the following to your package .aux4 to embed the skill.
Note: the 'prompt' command is OPTIONAL — keep it only for non-trivial skills
that need deep when/how/workflow/rules guidance. Add your domain commands to
the ai:skill:deploy profile. Do NOT add a 'run' command.

    {
      "name": "ai:skill",
      "commands": [
        ...
      ]
    }
```
