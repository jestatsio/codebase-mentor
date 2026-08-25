import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const testFile = fileURLToPath(import.meta.url);
const mcpRoot = path.resolve(path.dirname(testFile), "..");
const tempDir = mkdtempSync(path.join(tmpdir(), "codebase-mentor-mcp-"));
// Separate tree for the not-found case, so the walk-up can't reach the fixture.
const bareDir = mkdtempSync(path.join(tmpdir(), "codebase-mentor-mcp-bare-"));

// Fixture: ONBOARDING.md at tempDir root, with a nested dir to walk up from.
const fixtureContent = "# ONBOARDING.md — smoke fixture\n\nSymbol anchor: `fixtureSymbol()`.\n";
writeFileSync(path.join(tempDir, "ONBOARDING.md"), fixtureContent);
const nested = path.join(tempDir, "nested", "deeper");
mkdirSync(nested, { recursive: true });

try {
  const transport = new StdioClientTransport({
    command: "node",
    args: [path.join(mcpRoot, "build", "index.js")]
  });
  const client = new Client({ name: "codebase-mentor-smoke", version: "0.1.0" });
  await client.connect(transport); // initialize handshake

  try {
    const tools = await client.listTools();
    const toolNames = tools.tools.map((t) => t.name).sort();
    assert(
      JSON.stringify(toolNames) ===
        JSON.stringify([
          "codebase_mentor_get_onboarding",
          "codebase_mentor_get_protocol",
          "codebase_mentor_get_template"
        ]),
      `tools/list returned ${toolNames}`
    );

    const prompts = await client.listPrompts();
    const promptNames = prompts.prompts.map((p) => p.name).sort();
    assert(
      JSON.stringify(promptNames) ===
        JSON.stringify(["change_guide", "mentor", "onboard", "reconcile", "scan"]),
      `prompts/list returned ${promptNames}`
    );

    const reconcile = await client.getPrompt({
      name: "reconcile",
      arguments: { claim: "X handles Y" }
    });
    const reconcileText = reconcile.messages[0].content.text;
    assert(reconcileText.includes("Accuracy Contract"), "reconcile prompt embeds the protocol");
    assert(reconcileText.includes("X handles Y"), "reconcile prompt embeds the claim");

    const protocol = await client.callTool({
      name: "codebase_mentor_get_protocol",
      arguments: {}
    });
    assert(
      protocol.content[0].text.includes("Accuracy Contract"),
      "get_protocol returns the protocol text"
    );

    const found = await client.callTool({
      name: "codebase_mentor_get_onboarding",
      arguments: { root: nested }
    });
    assert(found.content[0].text.includes(fixtureContent), "get_onboarding walks up and returns content");
    assert(
      found.content[0].text.includes(path.join(tempDir, "ONBOARDING.md")),
      "get_onboarding reports the discovered path"
    );

    const missing = await client.callTool({
      name: "codebase_mentor_get_onboarding",
      arguments: { root: bareDir }
    });
    assert(
      missing.content[0].text.includes("No ONBOARDING.md found"),
      "get_onboarding reports not-found"
    );
    assert(
      missing.content[0].text.includes("onboard"),
      "not-found message suggests the onboard prompt"
    );

    console.log("smoke: all assertions passed.");
  } finally {
    // Always tear down the spawned server process, even if an assertion throws.
    await client.close();
  }
} finally {
  rmSync(tempDir, { recursive: true, force: true });
  rmSync(bareDir, { recursive: true, force: true });
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}
