# ai skill export

## skill format (default)

### should emit SKILL.md frontmatter with name and description

```execute
aux4 ai skill export example
```

```expect:partial
---
name: example
description: Discover and run aux4 commands to accomplish a user's task.
---
```

### should include the instructions body

```execute
aux4 ai skill export example --format skill
```

```expect:partial
You are an aux4 agent skill
```

## agents format

### should emit an AGENTS.md-style markdown document

```execute
aux4 ai skill export example --format agents
```

```expect:partial
# example
```

### should include an Instructions section

```execute
aux4 ai skill export example --format agents
```

```expect:partial
## Instructions
```

## mcp format

### should emit the MCP tool name

```execute
aux4 ai skill export example --format mcp
```

```expect:partial
"name": "example",
```

### should declare an object input schema requiring a question

```execute
aux4 ai skill export example --format mcp
```

```expect:partial
  "inputSchema": {
    "type": "object",
```

### should wrap the skill instructions

```execute
aux4 ai skill export example --format mcp
```

```expect:partial
"instructions": "Discover and run aux4 commands
```

### should produce valid JSON

```execute
aux4 ai skill export example --format mcp | python3 -c 'import sys,json; print(json.load(sys.stdin)["name"])'
```

```expect
example
```

## output to file

```afterAll
rm -f export-out.md
```

### should write the export to a file

```execute
aux4 ai skill export example --format skill --output export-out.md
```

```expect
Exported skill 'example' to export-out.md
```

### should write the SKILL.md content to the file

```execute
cat export-out.md
```

```expect:partial
name: example
```
