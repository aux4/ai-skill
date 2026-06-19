#### Description

The `init` command scaffolds a new native skill in the current working directory.

It creates `instructions/<name>.md` with a starter template — but only if that file does not already exist, so it never overwrites your work. It then prints the exact `.aux4` profile snippet you should add to your package to embed the skill: a `<name>` command in the `ai:skill` profile plus an `ai:skill:<name>` profile exposing `prompt` (which `cat`s the instructions, no AI dependency) and `run` (which calls `aux4 ai agent ask`).

This is the recommended starting point for authoring a skill that other agents can discover with `aux4 ai skill list` and export with `aux4 ai skill export`.

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
Created instructions/deploy.md

Add the following to your package .aux4 to embed the skill:

    {
      "name": "ai:skill",
      "commands": [
        ...
      ]
    }
```
