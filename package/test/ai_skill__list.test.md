# ai skill list

## listing native skills

### should include the bundled example skill with its description

```execute
aux4 ai skill list
```

```expect:partial
example  -  Example skill: how to author and use aux4 skills
```

### should not list the reserved export command as a skill

```execute
aux4 ai skill list | grep -c "^export  -" || true
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
