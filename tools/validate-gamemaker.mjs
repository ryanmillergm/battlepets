import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const projectText = readFileSync(resolve(root, "battlepets.yyp"), "utf8").replace(/,\s*([}\]])/g, "$1");
const project = JSON.parse(projectText);
const seen = new Set();
const errors = [];

for (const resource of project.resources ?? []) {
  const name = resource?.id?.name;
  const path = resource?.id?.path;
  if (!name || !path) {
    errors.push("Project contains a resource without a name or path");
    continue;
  }
  if (seen.has(name)) errors.push(`Duplicate GameMaker resource name: ${name}`);
  seen.add(name);
  if (!existsSync(resolve(root, path))) errors.push(`Missing GameMaker resource: ${path}`);
}

if (errors.length) {
  console.error(errors.join("\n"));
  process.exit(1);
}
console.log(`Validated ${seen.size} GameMaker resources.`);
