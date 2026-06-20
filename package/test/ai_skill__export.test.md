# ai skill export

These tests register a throwaway fixture skill (with a `prompt` command that
prints instructions) in the current directory's `.aux4`, then export it to each
interop format. `export` reads the skill body via `aux4 ai skill <name> prompt`.

```file:.aux4
{
  "profiles": [
    {
      "name": "ai:skill",
      "commands": [
        {
          "name": "fixture",
          "execute": [
            "profile:ai:skill:fixture"
          ],
          "help": {
            "text": "A throwaway fixture skill for testing"
          }
        }
      ]
    },
    {
      "name": "ai:skill:fixture",
      "commands": [
        {
          "name": "prompt",
          "execute": [
            "printf 'Deploy applications using aux4 commands.\\n\\nYou are an aux4 agent skill that deploys apps.\\n'"
          ],
          "help": {
            "text": "Show the fixture skill instructions"
          }
        }
      ]
    }
  ]
}
```

## skill format (default)

### should emit SKILL.md frontmatter with name and description

```execute
aux4 ai skill export fixture
```

```expect:partial
---
name: fixture
description: Deploy applications using aux4 commands.
---
```

### should include the instructions body

```execute
aux4 ai skill export fixture --format skill
```

```expect:partial
You are an aux4 agent skill that deploys apps.
```

## agents format

### should emit an AGENTS.md-style markdown document

```execute
aux4 ai skill export fixture --format agents
```

```expect:partial
# fixture
```

### should include an Instructions section

```execute
aux4 ai skill export fixture --format agents
```

```expect:partial
## Instructions
```

## mcp format

### should emit the MCP tool name

```execute
aux4 ai skill export fixture --format mcp
```

```expect:partial
"name": "fixture",
```

### should declare an object input schema requiring a question

```execute
aux4 ai skill export fixture --format mcp
```

```expect:partial
  "inputSchema": {
    "type": "object",
```

### should wrap the skill instructions

```execute
aux4 ai skill export fixture --format mcp
```

```expect:partial
"instructions": "Deploy applications using aux4 commands.
```

### should produce valid JSON

```execute
aux4 ai skill export fixture --format mcp | python3 -c 'import sys,json; print(json.load(sys.stdin)["name"])'
```

```expect
fixture
```

## output to file

```afterAll
rm -f export-out.md
```

### should write the export to a file

```execute
aux4 ai skill export fixture --format skill --output export-out.md
```

```expect
Exported skill 'fixture' to export-out.md
```

### should write the SKILL.md content to the file

```execute
cat export-out.md
```

```expect:partial
name: fixture
```
