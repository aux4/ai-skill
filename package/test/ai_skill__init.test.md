# ai skill init

```afterAll
rm -rf instructions
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

### should print the .aux4 profile snippet to embed the skill

```execute
aux4 ai skill init deploy
```

```expect:partial
"name": "ai:skill:deploy"
```

### should not overwrite existing instructions

```execute
aux4 ai skill init deploy
```

```expect:partial
already exist
```
