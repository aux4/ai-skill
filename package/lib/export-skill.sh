#!/bin/sh
# Export an aux4 native skill to an interop format.
#
# Usage: export-skill.sh <name> <format> [output]
#   name    - the skill name (an `ai:skill:<name>` profile must exist)
#   format  - one of: skill | agents | mcp   (default: skill)
#   output  - optional file path; when empty the result goes to stdout
#
# The skill instructions are read via `aux4 ai skill <name> prompt`, which by
# convention prints the skill's instructions markdown with no AI dependency.

set -e

name="$1"
format="$2"
output="$3"

if [ -z "$name" ]; then
  echo "Error: skill name is required" >&2
  exit 1
fi

if [ -z "$format" ]; then
  format="skill"
fi

# Read the skill instructions (the body for every format).
instructions=$(aux4 ai skill "$name" prompt 2>/dev/null || true)

if [ -z "$instructions" ]; then
  echo "Error: skill '$name' not found or has no instructions" >&2
  exit 1
fi

# Derive a one-line description from the first non-empty, non-heading line of
# the instructions. Falls back to a generic description.
description=$(printf '%s\n' "$instructions" | awk '
  /^[[:space:]]*$/ { next }
  /^#/ { next }
  { print; exit }
')
if [ -z "$description" ]; then
  description="aux4 native skill: $name"
fi

# json_escape escapes a multi-line string for safe embedding in a JSON value,
# joining lines with literal \n escapes.
json_escape() {
  printf '%s' "$1" | awk '
    BEGIN { ORS=""; first=1 }
    {
      gsub(/\\/, "\\\\")
      gsub(/"/, "\\\"")
      gsub(/\t/, "\\t")
      gsub(/\r/, "")
      if (!first) printf "\\n"
      printf "%s", $0
      first=0
    }
  '
}

# json_escape_inline escapes a single-line string (no trailing newline).
json_escape_inline() {
  printf '%s' "$1" | awk '
    BEGIN { ORS="" }
    {
      gsub(/\\/, "\\\\")
      gsub(/"/, "\\\"")
      gsub(/\t/, "\\t")
      gsub(/\r/, "")
      printf "%s", $0
    }
  '
}

render() {
  case "$format" in
    skill)
      printf -- '---\n'
      printf 'name: %s\n' "$name"
      printf 'description: %s\n' "$description"
      printf -- '---\n\n'
      printf '%s\n' "$instructions"
      ;;
    agents)
      printf '# %s\n\n' "$name"
      printf '%s\n\n' "$description"
      printf '## Instructions\n\n'
      printf '%s\n' "$instructions"
      ;;
    mcp)
      esc_desc=$(json_escape_inline "$description")
      esc_instr=$(json_escape "$instructions")
      printf '{\n'
      printf '  "name": "%s",\n' "$name"
      printf '  "description": "%s",\n' "$esc_desc"
      printf '  "inputSchema": {\n'
      printf '    "type": "object",\n'
      printf '    "properties": {\n'
      printf '      "question": {\n'
      printf '        "type": "string",\n'
      printf '        "description": "The question or task for the %s skill"\n' "$name"
      printf '      }\n'
      printf '    },\n'
      printf '    "required": [\n'
      printf '      "question"\n'
      printf '    ]\n'
      printf '  },\n'
      printf '  "instructions": "%s"\n' "$esc_instr"
      printf '}\n'
      ;;
    *)
      echo "Error: unsupported format '$format' (use skill, agents, or mcp)" >&2
      exit 1
      ;;
  esac
}

if [ -n "$output" ]; then
  render > "$output"
  echo "Exported skill '$name' to $output"
else
  render
fi
