import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const source = fs.readFileSync(
  path.resolve(process.cwd(), "src", "index.ts"),
  "utf8",
);

test("commercial access callables remain locked-admin and request based", () => {
  assert.match(
    source,
    /export const listPendingCommercialAccessRequests = onCall[\s\S]*?assertLockedAdmin\(request\)/,
  );
  assert.match(
    source,
    /export const approveCommercialAccessRequest = onCall[\s\S]*?const adminUid = assertLockedAdmin\(request\)/,
  );
  assert.match(source, /readCommercialRequestId\(payload\.requestId\)/);
  assert.doesNotMatch(
    source,
    /approveCommercialAccessRequest[\s\S]*?payload\.userId/,
  );
});

test("commercial access approval permits only fixed short durations", () => {
  assert.match(source, /new Set<number>\(\[1, 3, 7, 10\]\)/);
  assert.match(
    source,
    /durationDays must be exactly 1, 3, 7, or 10/,
  );
});

test("commercial access defaults remain server controlled", () => {
  assert.match(source, /deviceAllowance: 1/);
  assert.match(
    source,
    /grantedEntitlements: \["baseEncoding", "baseDecoding"\]/,
  );
  assert.doesNotMatch(
    source,
    /payload\.deviceAllowance|payload\.grantedEntitlements|payload\.camouflage/,
  );
});