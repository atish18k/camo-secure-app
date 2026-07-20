import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import test from "node:test";

const source = readFileSync(join(process.cwd(), "src", "index.ts"), "utf8");

test("authorizeOperation returns the orchestrator signed response", () => {
  assert.match(
    source,
    /result\s*=\s*await\s+authorizationOrchestrator\.authorize\(context\)/,
  );
  assert.match(
    source,
    /if\s*\(\s*!result\.authorized\s*\|\|\s*result\.signedResponse\s*===\s*undefined\s*\)/,
  );
  assert.match(source, /return\s+result\.signedResponse\s*;/);
});

test("authorizeOperation no longer contains the frozen activation block", () => {
  assert.doesNotMatch(
    source,
    /CAMO production authorization activation remains blocked\./,
  );
});

test("authorizeOperation retains authentication and App Check gates", () => {
  assert.match(source, /request\.auth\s*===\s*undefined/);
  assert.match(source, /request\.app\s*===\s*undefined/);
  assert.match(source, /input\.userId\s*!==\s*request\.auth\.uid/);
});

test("authorizeOperation retains fail-closed denial and pipeline failure paths", () => {
  assert.match(source, /CAMO authorization pipeline failed closed\./);
  assert.match(source, /CAMO server authorization was denied\./);
  assert.match(source, /createFailClosedDenial\(\)/);
});
