#!/bin/sh
# Scaffold a new aux4 native skill in the current working directory.
#
# Usage: init-skill.sh <name>
#
# Creates instructions/<name>.md with a starter template (only when it does not
# already exist) and prints the .aux4 profile snippet to embed the skill.

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

echo ""
echo "Add the following to your package .aux4 to embed the skill:"
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
            "text": "Show the $name skill instructions"
          }
        },
        {
          "name": "run",
          "execute": [
            "aux4 ai agent ask --instructions \${packageDir}/instructions/$name.md param(question)"
          ],
          "help": {
            "text": "Run the $name skill with a question",
            "variables": [
              {
                "name": "question",
                "text": "The question to ask the $name skill",
                "arg": true
              }
            ]
          }
        }
      ]
    }
EOF
