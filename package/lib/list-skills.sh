#!/bin/sh
# List installed native aux4 skills by parsing `aux4 ai skill --help`.
#
# The help output lists each command in the `ai:skill` profile as a name line
# indented by exactly two spaces, followed by a two-space-indented description
# line. Reserved framework commands (list, validate, export, init) are excluded
# so that only contributed skills are shown.
#
# Output format (one skill per line):
#   <name>  -  <description>

set -e

# Capture the profile help. Strip ANSI color codes so parsing is deterministic.
help=$(aux4 ai skill --help 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g')

printf '%s\n' "$help" | awk '
  # A command name line: exactly two leading spaces, then a non-dash word.
  /^  [^ -][^ ]*[[:space:]]*$/ {
    name = $1
    if (name == "list" || name == "validate" || name == "export" || name == "init") {
      pending = ""
      next
    }
    pending = name
    next
  }
  # The description line immediately follows the name line (two-space indent).
  pending != "" && /^  [^ ]/ {
    desc = $0
    sub(/^  /, "", desc)
    printf "%s  -  %s\n", pending, desc
    pending = ""
    next
  }
'
