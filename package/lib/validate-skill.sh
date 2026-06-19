#!/bin/sh
# Validate that a native aux4 skill conforms to the skill contract.
#
# Usage: validate-skill.sh <name>
#
# Checks performed against the installed skill (discovered the same way as `list`,
# by parsing `aux4 ai skill --help` and `aux4 ai skill <name> --help`):
#
#   1. REGISTERED  - the skill contributes a `<name>` command to the `ai:skill`
#                    profile (i.e. it shows up under `aux4 ai skill --help`).
#   2. HELP TEXT   - that `<name>` command has a non-empty help.text / description
#                    (the REQUIRED discovery layer).
#   3. COMMANDS    - the skill exposes at least one command in its
#                    `ai:skill:<name>` profile (recommended — a skill with no
#                    commands does nothing).
#
# `prompt` is OPTIONAL and is NOT required. `run` is NOT part of the contract and
# is NOT required (and a present `run` is not a failure here — the framework just
# does not depend on it).
#
# Prints a clear pass/fail report and exits non-zero on failure.

set -e

name="$1"

if [ -z "$name" ]; then
  echo "Error: skill name is required" >&2
  exit 1
fi

strip_ansi() {
  sed 's/\x1b\[[0-9;]*m//g'
}

# --- Check 1 & 2: registered under ai:skill with a help.text -----------------
skill_help=$(aux4 ai skill --help 2>/dev/null | strip_ansi || true)

# Find the description that sits on the line right after the `<name>` line.
# Reserved framework commands are not skills.
description=$(printf '%s\n' "$skill_help" | awk -v target="$name" '
  /^  [^ -][^ ]*[[:space:]]*$/ {
    cmd = $1
    if (cmd == target) { found = 1; next }
    found = 0
    next
  }
  found && /^  [^ ]/ {
    line = $0
    sub(/^  /, "", line)
    print line
    exit
  }
')

registered=0
if printf '%s\n' "$skill_help" | awk -v target="$name" '
  /^  [^ -][^ ]*[[:space:]]*$/ { if ($1 == target) { found=1 } }
  END { exit (found ? 0 : 1) }
'; then
  registered=1
fi

# --- Check 3: at least one command in the ai:skill:<name> profile ------------
command_count=0
if [ "$registered" -eq 1 ]; then
  sub_help=$(aux4 ai skill "$name" --help 2>/dev/null | strip_ansi || true)
  command_count=$(printf '%s\n' "$sub_help" | awk '
    /^  [^ -][^ ]*[[:space:]]*$/ { count++ }
    END { print count + 0 }
  ')
fi

# --- Report ------------------------------------------------------------------
pass=1

echo "Validating native skill: $name"
echo ""

if [ "$registered" -eq 1 ]; then
  echo "  [PASS] registered under the ai:skill profile"
else
  echo "  [FAIL] not registered under the ai:skill profile"
  echo "         add a '$name' command to the ai:skill profile (see 'aux4 ai skill init $name')"
  pass=0
fi

if [ "$registered" -eq 1 ] && [ -n "$description" ]; then
  echo "  [PASS] has help.text: $description"
else
  echo "  [FAIL] missing help.text (the required discovery layer)"
  pass=0
fi

if [ "$command_count" -gt 0 ]; then
  echo "  [PASS] exposes $command_count command(s) in the ai:skill:$name profile"
else
  echo "  [WARN] exposes no commands — a skill should provide at least one capability or a 'prompt'"
fi

echo ""

if [ "$pass" -eq 1 ]; then
  echo "Skill '$name' conforms to the native skill contract."
  exit 0
else
  echo "Skill '$name' does NOT conform to the native skill contract."
  exit 1
fi
