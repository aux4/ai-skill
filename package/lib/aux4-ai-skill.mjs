#!/usr/bin/env node
// aux4/ai-skill — native skill framework dispatcher.
//
// Reimplements the four framework commands in plain Node (no npm deps):
//   list      — discover installed native skills by parsing `aux4 ai skill --help`
//   validate  — check a skill against the native skill contract
//   export    — export a skill to an interop format (skill | agents | mcp)
//   init      — scaffold a new native skill in the current directory
//
// Invoked from .aux4 as:
//   node ${packageDir}/lib/aux4-ai-skill.mjs <cmd> values(...)

import fs from "fs";
import path from "path";
import { execFileSync } from "child_process";

const RESERVED = new Set(["list", "validate", "export", "init"]);

// Strip ANSI color codes so help parsing is deterministic.
function stripAnsi(text) {
  return text.replace(/\x1b\[[0-9;]*m/g, "");
}

// Run an aux4 command and return its stdout (empty string on failure).
function aux4Help(args) {
  try {
    const out = execFileSync("aux4", args, {
      encoding: "utf-8",
      stdio: ["ignore", "pipe", "ignore"]
    });
    return stripAnsi(out);
  } catch (err) {
    // Mirror the shell `|| true` behavior: still return whatever was captured.
    const out = err.stdout ? stripAnsi(err.stdout.toString()) : "";
    return out;
  }
}

// Parse a profile's --help into [{ name, description }] command entries.
//
// The help output lists each command as a name line indented by exactly two
// spaces (the name, no leading dash), followed by a two-space-indented
// description line.
function parseHelpCommands(help) {
  const lines = help.split("\n");
  const commands = [];
  let pendingName = null;

  for (const line of lines) {
    // A command name line: exactly two leading spaces, then a non-dash word,
    // then only whitespace.
    if (/^ {2}[^ -]\S*\s*$/.test(line)) {
      pendingName = line.trim().split(/\s+/)[0];
      continue;
    }
    // The description line immediately follows the name line (two-space indent).
    if (pendingName !== null && /^ {2}\S/.test(line)) {
      const desc = line.replace(/^ {2}/, "");
      commands.push({ name: pendingName, description: desc });
      pendingName = null;
      continue;
    }
    // Any other line breaks a pending name with no description.
    if (pendingName !== null && line.trim() === "") {
      // keep pending across blank lines? shell awk only matched the immediately
      // following two-space line; a blank line drops the pending name.
      pendingName = null;
    }
  }

  return commands;
}

// ---------------------------------------------------------------------------
// list
// ---------------------------------------------------------------------------
function cmdList() {
  const help = aux4Help(["ai", "skill", "--help"]);
  const commands = parseHelpCommands(help);
  const out = [];
  for (const { name, description } of commands) {
    if (RESERVED.has(name)) continue;
    out.push(`${name}  -  ${description}`);
  }
  if (out.length > 0) {
    process.stdout.write(out.join("\n") + "\n");
  }
}

// ---------------------------------------------------------------------------
// validate
// ---------------------------------------------------------------------------
function cmdValidate(name) {
  if (!name) {
    process.stderr.write("Error: skill name is required\n");
    process.exit(1);
  }

  // Check 1 & 2: registered under ai:skill with a help.text / description.
  const skillHelp = aux4Help(["ai", "skill", "--help"]);
  const commands = parseHelpCommands(skillHelp);
  const entry = commands.find(c => c.name === name);
  const registered = !!entry;
  const description = entry ? entry.description : "";

  // Check 3: at least one command in the ai:skill:<name> profile.
  let commandCount = 0;
  if (registered) {
    const subHelp = aux4Help(["ai", "skill", name, "--help"]);
    commandCount = parseHelpCommands(subHelp).length;
  }

  let pass = true;
  const lines = [];
  lines.push(`Validating native skill: ${name}`);
  lines.push("");

  if (registered) {
    lines.push("  [PASS] registered under the ai:skill profile");
  } else {
    lines.push("  [FAIL] not registered under the ai:skill profile");
    lines.push(`         add a '${name}' command to the ai:skill profile (see 'aux4 ai skill init ${name}')`);
    pass = false;
  }

  if (registered && description) {
    lines.push(`  [PASS] has help.text: ${description}`);
  } else {
    lines.push("  [FAIL] missing help.text (the required discovery layer)");
    pass = false;
  }

  if (commandCount > 0) {
    lines.push(`  [PASS] exposes ${commandCount} command(s) in the ai:skill:${name} profile`);
  } else {
    lines.push("  [WARN] exposes no commands — a skill should provide at least one capability or a 'prompt'");
  }

  lines.push("");

  if (pass) {
    lines.push(`Skill '${name}' conforms to the native skill contract.`);
    process.stdout.write(lines.join("\n") + "\n");
    process.exit(0);
  } else {
    lines.push(`Skill '${name}' does NOT conform to the native skill contract.`);
    process.stdout.write(lines.join("\n") + "\n");
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// export
// ---------------------------------------------------------------------------
function deriveDescription(instructions, name) {
  for (const raw of instructions.split("\n")) {
    if (raw.trim() === "") continue;
    if (raw.startsWith("#")) continue;
    return raw;
  }
  return `aux4 native skill: ${name}`;
}

// Escape a multi-line string for embedding in a JSON value, joining lines with
// literal \n escapes (matches the shell json_escape helper).
function jsonEscapeMultiline(text) {
  return text
    .split("\n")
    .map(line =>
      line
        .replace(/\\/g, "\\\\")
        .replace(/"/g, '\\"')
        .replace(/\t/g, "\\t")
        .replace(/\r/g, "")
    )
    .join("\\n");
}

function jsonEscapeInline(text) {
  return text
    .replace(/\r/g, "")
    .replace(/\\/g, "\\\\")
    .replace(/"/g, '\\"')
    .replace(/\t/g, "\\t");
}

function renderExport(name, format, instructions, description) {
  if (format === "skill") {
    return (
      "---\n" +
      `name: ${name}\n` +
      `description: ${description}\n` +
      "---\n\n" +
      `${instructions}\n`
    );
  }
  if (format === "agents") {
    return (
      `# ${name}\n\n` +
      `${description}\n\n` +
      "## Instructions\n\n" +
      `${instructions}\n`
    );
  }
  if (format === "mcp") {
    const escDesc = jsonEscapeInline(description);
    const escInstr = jsonEscapeMultiline(instructions);
    return (
      "{\n" +
      `  "name": "${name}",\n` +
      `  "description": "${escDesc}",\n` +
      '  "inputSchema": {\n' +
      '    "type": "object",\n' +
      '    "properties": {\n' +
      '      "question": {\n' +
      '        "type": "string",\n' +
      `        "description": "The question or task for the ${name} skill"\n` +
      "      }\n" +
      "    },\n" +
      '    "required": [\n' +
      '      "question"\n' +
      "    ]\n" +
      "  },\n" +
      `  "instructions": "${escInstr}"\n` +
      "}\n"
    );
  }
  process.stderr.write(`Error: unsupported format '${format}' (use skill, agents, or mcp)\n`);
  process.exit(1);
}

function cmdExport(name, format, output) {
  if (!name) {
    process.stderr.write("Error: skill name is required\n");
    process.exit(1);
  }
  if (!format) format = "skill";

  // Read the skill instructions (the body for every format).
  let instructions = aux4Help(["ai", "skill", name, "prompt"]);
  // Drop a single trailing newline so the body matches the shell capture
  // (command substitution strips trailing newlines).
  instructions = instructions.replace(/\n+$/, "");

  if (!instructions) {
    process.stderr.write(`Error: skill '${name}' not found or has no instructions\n`);
    process.exit(1);
  }

  const description = deriveDescription(instructions, name);
  const content = renderExport(name, format, instructions, description);

  if (output) {
    fs.writeFileSync(output, content);
    process.stdout.write(`Exported skill '${name}' to ${output}\n`);
  } else {
    process.stdout.write(content);
  }
}

// ---------------------------------------------------------------------------
// init
// ---------------------------------------------------------------------------
const INSTRUCTIONS_TEMPLATE = name => `# ${name} skill

You are an aux4 agent skill named \`${name}\`.

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
`;

const MAN_TEMPLATE = name => `#### Description

The \`prompt\` command prints the deep guidance for the \`${name}\` skill — when to
use it, the workflow to follow, and the rules to respect. This is the OPTIONAL
prose tier of the disclosure ladder, loaded on demand only when an agent engages
this skill. It has no AI dependency: it simply prints the instructions markdown.

#### Usage

\`\`\`bash
aux4 ai skill ${name} prompt
\`\`\`

#### Example

\`\`\`bash
aux4 ai skill ${name} prompt
\`\`\`
`;

const SNIPPET_TEMPLATE = name => `    {
      "name": "ai:skill",
      "commands": [
        {
          "name": "${name}",
          "execute": [
            "profile:ai:skill:${name}"
          ],
          "help": {
            "text": "Describe the ${name} skill here"
          }
        }
      ]
    },
    {
      "name": "ai:skill:${name}",
      "commands": [
        {
          "name": "prompt",
          "execute": [
            "cat \${packageDir}/instructions/${name}.md"
          ],
          "help": {
            "text": "Show the ${name} skill guidance (optional)"
          }
        }
      ]
    }`;

function cmdInit(name) {
  if (!name) {
    process.stderr.write("Error: skill name is required\n");
    process.exit(1);
  }

  fs.mkdirSync("instructions", { recursive: true });
  const file = path.join("instructions", `${name}.md`);

  if (fs.existsSync(file)) {
    console.log(`Skill instructions already exist at ${file} (left unchanged)`);
  } else {
    fs.writeFileSync(file, INSTRUCTIONS_TEMPLATE(name));
    console.log(`Created ${file}`);
  }

  fs.mkdirSync("man", { recursive: true });
  const manfile = path.join("man", `ai_skill_${name}__prompt.md`);

  if (fs.existsSync(manfile)) {
    console.log(`Man page already exists at ${manfile} (left unchanged)`);
  } else {
    fs.writeFileSync(manfile, MAN_TEMPLATE(name));
    console.log(`Created ${manfile}`);
  }

  console.log("");
  console.log("Add the following to your package .aux4 to embed the skill.");
  console.log("Note: the 'prompt' command is OPTIONAL — keep it only for non-trivial skills");
  console.log("that need deep when/how/workflow/rules guidance. Add your domain commands to");
  console.log(`the ai:skill:${name} profile. Do NOT add a 'run' command.`);
  console.log("");
  console.log(SNIPPET_TEMPLATE(name));
}

// ---------------------------------------------------------------------------
// dispatch
// ---------------------------------------------------------------------------
function main() {
  const [cmd, ...rest] = process.argv.slice(2);

  switch (cmd) {
    case "list":
      cmdList();
      break;
    case "validate":
      cmdValidate(rest[0]);
      break;
    case "export":
      cmdExport(rest[0], rest[1], rest[2]);
      break;
    case "init":
      cmdInit(rest[0]);
      break;
    default:
      process.stderr.write(`Error: unknown command '${cmd}' (use list, validate, export, or init)\n`);
      process.exit(1);
  }
}

main();
