import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, realpathSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const mcpRoot = fileURLToPath(new URL("../", import.meta.url));
const entrypoint = path.join(mcpRoot, "build", "index.js");
const { version } = JSON.parse(readFileSync(path.join(mcpRoot, "package.json"), "utf8"));
const tempDir = realpathSync(mkdtempSync(path.join(tmpdir(), "codebase-mentor-mcp-")));
const fixtureContent = "# ONBOARDING.md — smoke fixture\n\nSymbol anchor: `fixtureSymbol()`.\n";
let assertions = 0;
function check(condition, message) {
  assert.ok(condition, message);
  assertions++;
}
function fixtureDir(name) {
  const dir = path.join(tempDir, name);
  mkdirSync(dir, { recursive: true });
  return dir;
}
function resultText(result) {
  return result.content.map((part) => part.type === "text" ? part.text : "").join("\n");
}

try {
  writeFileSync(path.join(tempDir, "ONBOARDING.md"), fixtureContent);
  mkdirSync(path.join(tempDir, ".git"));
  const nested = fixtureDir("nested/deeper");
  const bareDir = fixtureDir("separate-repo");
  mkdirSync(path.join(bareDir, ".git"));
  const worktree = fixtureDir("worktree");
  writeFileSync(path.join(worktree, ".git"), "gitdir: /not/needed/for/discovery\n");

  const transport = new StdioClientTransport({
    command: process.execPath,
    args: [entrypoint, "--root", tempDir],
    // Simulate a desktop client launching outside the project.
    cwd: bareDir
  });
  const client = new Client({ name: "codebase-mentor-smoke", version });
  await client.connect(transport);

  try {
    check(client.getServerVersion().version === version, "handshake reports the package version");
    const tools = await client.listTools();
    assert.deepEqual(tools.tools.map((tool) => tool.name).sort(), [
      "codebase_mentor_get_onboarding", "codebase_mentor_get_protocol", "codebase_mentor_get_template"
    ]);
    check(tools.tools.every((tool) => tool.annotations?.readOnlyHint === true), "all tools declare read-only behavior");

    const prompts = await client.listPrompts();
    assert.deepEqual(prompts.prompts.map((prompt) => prompt.name).sort(), [
      "change_guide", "mentor", "onboard", "reconcile", "scan"
    ]);
    for (const [name, args, task] of [
      ["mentor", { question: "Where is fixtureSymbol?" }, "Where is fixtureSymbol?"],
      ["change_guide", { task: "Add fixture support" }, "Add fixture support"],
      ["reconcile", { claim: "X handles Y" }, "X handles Y"],
      ["scan", {}, "Scan mode"]
    ]) {
      const prompt = await client.getPrompt({ name, arguments: args });
      const text = prompt.messages[0].content.text;
      check(text.includes("Accuracy Contract") && text.includes(task), `${name} includes the protocol and task`);
    }
    const onboard = await client.getPrompt({ name: "onboard", arguments: {} });
    check(onboard.messages[0].content.text.includes(tempDir), "onboard uses the configured project root");
    check(onboard.messages[0].content.text.includes("Authoring guide"), "onboard includes the authoring guide");

    for (const compact of [false, true]) {
      const protocol = await client.callTool({ name: "codebase_mentor_get_protocol", arguments: { compact } });
      const canonical = readFileSync(path.join(mcpRoot, "bundled", compact ? "mentor-protocol-compact.md" : "mentor-protocol.md"), "utf8");
      check(resultText(protocol) === canonical, `protocol returns the exact ${compact ? "compact" : "full"} artifact`);
    }
    const template = await client.callTool({ name: "codebase_mentor_get_template", arguments: {} });
    check(resultText(template).includes(readFileSync(path.join(mcpRoot, "bundled", "ONBOARDING.template.md"), "utf8")), "template tool includes the bundled template");

    async function onboarding(root) {
      return client.callTool({ name: "codebase_mentor_get_onboarding", arguments: root === undefined ? {} : { root } });
    }
    check(resultText(await onboarding()).includes(fixtureContent), "--root overrides an unrelated server working directory");
    check(resultText(await onboarding(nested)).includes(fixtureContent), "discovery walks up from a nested directory");
    check(resultText(await onboarding("nested/deeper")).includes(fixtureContent), "relative tool paths resolve from the configured root");

    for (const root of [bareDir, worktree]) {
      const missing = await onboarding(root);
      check(resultText(missing).includes("No ONBOARDING.md found") && resultText(missing).includes("onboard"), "discovery stops at Git directories and worktree Git files");
    }
    writeFileSync(path.join(nested, "ONBOARDING.md"), "# Closest file\n");
    check(resultText(await onboarding(nested)).includes("# Closest file"), "discovery prefers the nearest ONBOARDING.md");

    const invalidDir = fixtureDir("invalid-file");
    mkdirSync(path.join(invalidDir, "ONBOARDING.md"));
    const largeDir = fixtureDir("oversized");
    writeFileSync(path.join(largeDir, "ONBOARDING.md"), "x".repeat(1024 * 1024 + 1));
    for (const [root, reason] of [
      [path.join(tempDir, "does-not-exist"), "nonexistent root"],
      [path.join(tempDir, "ONBOARDING.md"), "file passed as root"],
      [invalidDir, "directory named ONBOARDING.md"],
      [largeDir, "oversized document"]
    ]) {
      check((await onboarding(root)).isError === true, `rejects ${reason} with an MCP tool error`);
    }
    // Windows commonly requires extra privileges for file symlinks.
    if (process.platform !== "win32") {
      const linkedDir = fixtureDir("symlink");
      symlinkSync(path.join(tempDir, "ONBOARDING.md"), path.join(linkedDir, "ONBOARDING.md"));
      const linked = await onboarding(linkedDir);
      check(linked.isError === true && !resultText(linked).includes(fixtureContent), "refuses symlinks without disclosing their target content");
    }

    const resources = await client.listResources();
    assert.deepEqual(resources.resources.map((resource) => resource.uri).sort(), [
      "codebase-mentor://onboarding", "codebase-mentor://protocol"
    ]);
    const resource = await client.readResource({ uri: "codebase-mentor://onboarding" });
    check(resource.contents[0].text === fixtureContent, "onboarding resource uses --root");
    const protocolResource = await client.readResource({ uri: "codebase-mentor://protocol" });
    check(protocolResource.contents[0].text.includes("Accuracy Contract"), "protocol resource is readable");
    check(!(await onboarding()).isError, "server remains usable after invalid requests");
  } finally {
    await client.close();
  }

  check(execFileSync(process.execPath, [entrypoint, "--version"], { encoding: "utf8" }).trim() === version, "--version prints the package version");
  check(execFileSync(process.execPath, [entrypoint, "--help"], { encoding: "utf8" }).includes("--root"), "--help documents project selection");
  for (const args of [["--root"], ["--invalid"], ["--root", path.join(tempDir, "missing")]]) {
    assert.throws(() => execFileSync(process.execPath, [entrypoint, ...args], { stdio: "pipe" }), "invalid CLI arguments fail clearly");
    assertions++;
  }
  console.log(`smoke: ${assertions} assertions passed.`);
} finally {
  rmSync(tempDir, { recursive: true, force: true });
}
