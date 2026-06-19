#### Description

The `validate` command checks that an installed native skill conforms to the aux4 native skill contract. It discovers the skill the same way `list` does — by parsing `aux4 ai skill --help` and `aux4 ai skill <name> --help` — so it validates the skill as the runtime actually sees it.

It performs three checks:

- **Registered** — the skill contributes a `<name>` command to the shared `ai:skill` profile (it appears under `aux4 ai skill --help`). REQUIRED.
- **Help text** — that `<name>` command has a non-empty `help.text` description, the required discovery layer agents read first. REQUIRED.
- **Commands** — the skill exposes at least one command in its `ai:skill:<name>` profile. RECOMMENDED — a skill with no commands does nothing; a missing command set is reported as a warning, not a failure.

`prompt` is **optional** and is not required to pass. `run` is **not** part of the contract and is never required; the framework does not depend on it.

The command prints a per-check `[PASS]` / `[FAIL]` / `[WARN]` report and exits non-zero when the skill does not conform.

#### Usage

```bash
aux4 ai skill validate <name>
```

name   The name of the skill to validate (positional argument)

#### Example

```bash
aux4 ai skill validate memory
```

```text
Validating native skill: memory

  [PASS] registered under the ai:skill profile
  [PASS] has help.text: Persist and recall facts across agent runs
  [PASS] exposes 4 command(s) in the ai:skill:memory profile

Skill 'memory' conforms to the native skill contract.
```
