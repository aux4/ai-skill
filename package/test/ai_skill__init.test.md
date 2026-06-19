# ai skill init

```afterAll
rm -rf instructions man
```

## scaffolding a new skill

### should create the instructions template file

```execute
aux4 ai skill init deploy
```

```expect:partial
Created instructions/deploy.md
```

### should write a starter template into the instructions file

```execute
cat instructions/deploy.md
```

```expect:partial
# deploy skill
```

### should create the prompt man page stub

```execute
cat man/ai_skill_deploy__prompt.md
```

```expect:partial
The `prompt` command prints the deep guidance for the `deploy` skill
```

### should print the .aux4 profile snippet to embed the skill

```execute
aux4 ai skill init deploy
```

```expect:partial
"name": "ai:skill:deploy"
```

### should mark the prompt command as optional in the guidance

```execute
aux4 ai skill init deploy
```

```expect:partial
the 'prompt' command is OPTIONAL
```

### should NOT emit a run command in the snippet

```execute
aux4 ai skill init deploy | grep -c '"name": "run"' || true
```

```expect
0
```

### should NOT reference aux4 ai agent ask in the snippet

```execute
aux4 ai skill init deploy | grep -c "ai agent ask" || true
```

```expect
0
```

### should not overwrite existing instructions

```execute
aux4 ai skill init deploy
```

```expect:partial
already exist
```
