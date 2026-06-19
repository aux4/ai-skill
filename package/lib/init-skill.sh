#!/bin/sh
# Scaffold a new aux4 native skill in the current working directory.
#
# Usage: init-skill.sh <name>
#
# Creates (only when they do not already exist):
#   - instructions/<name>.md  : starter prompt template (OPTIONAL deep guidance)
#   - man/ai_skill_<name>__prompt.md : man page stub for the optional prompt command
# and prints the .aux4 profile snippet to embed the skill.
#
# The generated snippet conforms to the native skill contract:
#   - a <name> routing command under the `ai:skill` profile WITH help.text (REQUIRED)
#   - an `ai:skill:<name>` profile exposing an OPTIONAL `prompt` command
#   - NO `run` command (running a skill is a runtime concern, not part of the contract)

set -e

name="$1"

if [ -z "$name" ]; then
  echo "Error: skill name is required" >&2
  exit 1
fi

mkdir -p instructions
file="instructions/$name.md"

if [ -f "$file" ]; then
  echo "Skill instructions already exist at $file (left unchanged)"
else
  cat > "$file" <<EOF
# $name skill

You are an aux4 agent skill named \`$name\`.

Describe here what this skill teaches the agent to do, and the aux4 commands it
should use to accomplish the task.

## When to use this skill

Explain the situations where this skill applies.

## How to use it

1. Inspect the relevant commands with \`aux4 <profile> <command> --help\`.
2. Run the commands, passing parameters with \`--flag value\` or positionally.
3. Return a clear result to the user.

## Rules

- Only run the commands needed to complete the task.
- Return the result, not a description of the steps.
EOF
  echo "Created $file"
fi

mkdir -p man
manfile="man/ai_skill_${name}__prompt.md"

if [ -f "$manfile" ]; then
  echo "Man page already exists at $manfile (left unchanged)"
else
  cat > "$manfile" <<EOF
#### Description

The \`prompt\` command prints the deep guidance for the \`$name\` skill — when to
use it, the workflow to follow, and the rules to respect. This is the OPTIONAL
prose tier of the disclosure ladder, loaded on demand only when an agent engages
this skill. It has no AI dependency: it simply prints the instructions markdown.

#### Usage

\`\`\`bash
aux4 ai skill $name prompt
\`\`\`

#### Example

\`\`\`bash
aux4 ai skill $name prompt
\`\`\`
EOF
  echo "Created $manfile"
fi

echo ""
echo "Add the following to your package .aux4 to embed the skill."
echo "Note: the 'prompt' command is OPTIONAL — keep it only for non-trivial skills"
echo "that need deep when/how/workflow/rules guidance. Add your domain commands to"
echo "the ai:skill:$name profile. Do NOT add a 'run' command."
echo ""
cat <<EOF
    {
      "name": "ai:skill",
      "commands": [
        {
          "name": "$name",
          "execute": [
            "profile:ai:skill:$name"
          ],
          "help": {
            "text": "Describe the $name skill here"
          }
        }
      ]
    },
    {
      "name": "ai:skill:$name",
      "commands": [
        {
          "name": "prompt",
          "execute": [
            "cat \${packageDir}/instructions/$name.md"
          ],
          "help": {
            "text": "Show the $name skill guidance (optional)"
          }
        }
      ]
    }
EOF
