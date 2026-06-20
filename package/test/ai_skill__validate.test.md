# ai skill validate

These tests register throwaway fixture skills in the current directory's `.aux4`
(merged into the `ai:skill` profile) and check that `validate` reports pass/fail
against the native skill contract.

```file:.aux4
{
  "profiles": [
    {
      "name": "ai:skill",
      "commands": [
        {
          "name": "good",
          "execute": [
            "profile:ai:skill:good"
          ],
          "help": {
            "text": "A conforming fixture skill"
          }
        },
        {
          "name": "nohelp",
          "execute": [
            "profile:ai:skill:nohelp"
          ],
          "help": {
            "text": ""
          }
        }
      ]
    },
    {
      "name": "ai:skill:good",
      "commands": [
        {
          "name": "hello",
          "execute": [
            "echo hi"
          ],
          "help": {
            "text": "Say hi"
          }
        }
      ]
    },
    {
      "name": "ai:skill:nohelp",
      "commands": []
    }
  ]
}
```

## a conforming skill

### should report it is registered under the ai:skill profile

```execute
aux4 ai skill validate good
```

```expect:partial
[PASS] registered under the ai:skill profile
```

### should report it has help.text

```execute
aux4 ai skill validate good
```

```expect:partial
[PASS] has help.text: A conforming fixture skill
```

### should report it exposes at least one command

```execute
aux4 ai skill validate good
```

```expect:partial
[PASS] exposes 1 command(s) in the ai:skill:good profile
```

### should conclude it conforms to the contract

```execute
aux4 ai skill validate good
```

```expect:partial
Skill 'good' conforms to the native skill contract.
```

### should exit zero for a conforming skill

```execute
aux4 ai skill validate good >/dev/null; echo "exit=$?"
```

```expect
exit=0
```

## a non-conforming skill (missing help.text)

### should fail the help.text check

```execute
aux4 ai skill validate nohelp || true
```

```expect:partial
[FAIL] missing help.text (the required discovery layer)
```

### should conclude it does not conform

```execute
aux4 ai skill validate nohelp || true
```

```expect:partial
Skill 'nohelp' does NOT conform to the native skill contract.
```

## an unregistered skill

### should fail the registration check

```execute
aux4 ai skill validate ghost || true
```

```expect:partial
[FAIL] not registered under the ai:skill profile
```

### should exit non-zero for a non-conforming skill

```execute
aux4 ai skill validate ghost >/dev/null 2>&1; echo "exit=$?"
```

```expect
exit=1
```
