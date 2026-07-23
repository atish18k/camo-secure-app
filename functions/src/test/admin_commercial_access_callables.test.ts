import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const source = fs.readFileSync(
  path.resolve(process.cwd(), "src", "index.ts"),
  "utf8",
);

function callableSource(
  startMarker: string,
  endMarker: string,
): string {
  const start = source.indexOf(startMarker);
  const end = source.indexOf(endMarker, start);

  assert.ok(start >= 0);
  assert.ok(end > start);

  return source.slice(start, end);
}

test("commercial access callables remain locked-admin and request based", () => {
  const approval = callableSource(
    "export const approveCommercialAccessRequest = onCall",
    "export const listActiveCommercialAccess = onCall",
  );

  assert.match(approval, /const adminUid = assertLockedAdmin\(request\)/);
  assert.match(approval, /payload\.requestId/);
  assert.match(approval, /payload\.durationDays/);
  assert.doesNotMatch(approval, /payload\.userId/);
  assert.doesNotMatch(approval, /payload\.deviceAllowance/);
  assert.doesNotMatch(approval, /payload\.grantedEntitlements/);
  assert.doesNotMatch(approval, /payload\.expiresAt/);
});

test("commercial access approval permits only fixed short durations", () => {
  assert.match(
    source,
    /new Set<number>\(\[1,\s*3,\s*7,\s*10\]\)/,
  );
  assert.match(
    source,
    /durationDays must be exactly 1, 3, 7, or 10\./,
  );
});

test("commercial access defaults remain server controlled", () => {
  const approval = callableSource(
    "export const approveCommercialAccessRequest = onCall",
    "export const listActiveCommercialAccess = onCall",
  );

  assert.match(approval, /planId:\s*"camo_monthly_inr_199"/);
  assert.match(approval, /monthlyPriceInr:\s*199/);
  assert.match(approval, /deviceAllowance:\s*1/);
  assert.match(
    approval,
    /grantedEntitlements:\s*\["baseEncoding",\s*"baseDecoding"\]/,
  );
  assert.doesNotMatch(approval, /payload\.planId/);
  assert.doesNotMatch(approval, /payload\.monthlyPriceInr/);
  assert.doesNotMatch(approval, /payload\.deviceAllowance/);
  assert.doesNotMatch(approval, /payload\.grantedEntitlements/);
});
