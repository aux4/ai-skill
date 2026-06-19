#### Description

The `list` command discovers the native skills installed on the machine and prints a catalog of skill names and their descriptions.

It works by parsing the output of `aux4 ai skill --help`, which enumerates every command contributed to the `ai:skill` profile. The reserved framework commands (`list`, `validate`, `export`, and `init`) are excluded so that only contributed skills are shown. The parsing strips terminal color codes, so the output is deterministic and testable. On a clean install the framework ships skills-free, so `list` returns no output until packages contribute skills.

Each line of output has the form:

```text
<name>  -  <description>
```

#### Usage

```bash
aux4 ai skill list
```

#### Example

```bash
aux4 ai skill list
```

```text
deploy  -  Deploy applications using aux4 commands
```
