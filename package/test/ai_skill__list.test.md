# ai skill list

The framework ships skills-free. These tests register a throwaway fixture skill
in the current directory's `.aux4` (merged into the `ai:skill` profile) and check
that `list` discovers it and excludes the reserved framework commands.

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
            "echo fixture guidance"
          ],
          "help": {
            "text": "Show the fixture skill guidance"
          }
        }
      ]
    }
  ]
}
```

## listing native skills

### should include the registered fixture skill with its description

```execute
aux4 ai skill list
```

```expect:partial
fixture  -  A throwaway fixture skill for testing
```

### should not list the reserved export command as a skill

```execute
aux4 ai skill list | grep -c "^export  -" || true
```

```expect
0
```

### should not list the reserved validate command as a skill

```execute
aux4 ai skill list | grep -c "^validate  -" || true
```

```expect
0
```

### should not list the reserved init command as a skill

```execute
aux4 ai skill list | grep -c "^init  -" || true
```

```expect
0
```
