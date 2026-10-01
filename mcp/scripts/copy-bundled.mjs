import { copyFileSync, mkdirSync, readdirSync } from "node:fs";

// Node's filesystem API keeps the build usable on Windows as well as macOS/Linux.
const source = new URL("../bundled/", import.meta.url);
const destination = new URL("../build/bundled/", import.meta.url);
mkdirSync(destination, { recursive: true });
for (const file of readdirSync(source)) {
  if (file.endsWith(".md")) copyFileSync(new URL(file, source), new URL(file, destination));
}
