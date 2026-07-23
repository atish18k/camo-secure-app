import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const source = fs.readFileSync(
  path.resolve(process.cwd(), "src", "index.ts"),
  "utf8",
);

function approvalHandlerSource(): string {
  const approvalStart = source.indexOf(
    "export const approveCommercialAccessRequest = onCall",
  );
  const nextSection = source.indexOf(
    "const authorizationOrchestrator =",
    approvalStart,
  );

  assert.ok(approvalStart >= 0);
  assert.ok(nextSection > approvalStart);

  return source.slice(approvalStart, nextSection);
}

test("approval resolves target user from the pending request", () => {
  const handler = approvalHandlerSource();

  assert.match(
    handler,
    /\.collection\("commercialAccessRequestsV1"\)[\s\S]*?\.doc\(requestId\)/,
  );
  assert.match(handler, /pending\.userId !== requestId/);
  assert.match(
    handler,
    /\.collection\("users"\)[\s\S]*?\.doc\(pending\.userId\)/,
  );
  assert.doesNotMatch(handler, /payload\.userId/);
});

test("approval writes exact canonical commercialAccessV2 facts", () => {
  const handler = approvalHandlerSource();

  assert.match(handler, /collection\("commercialAccessV2"\)/);
  assert.match(handler, /\.doc\("current"\)/);
  assert.match(handler, /schemaVersion:\s*2/);
  assert.match(handler, /planId:\s*"camo_monthly_inr_199"/);
  assert.match(handler, /monthlyPriceInr:\s*199/);
  assert.match(handler, /licenseStatus:\s*"active"/);
  assert.match(handler, /subscriptionStatus:\s*"active"/);
  assert.match(handler, /billingState:\s*"paid"/);
  assert.match(handler, /deviceAllowance:\s*1/);
  assert.match(
    handler,
    /grantedEntitlements:\s*\["baseEncoding",\s*"baseDecoding"\]/,
  );
  assert.match(handler, /startsAt:\s*now/);
  assert.match(handler, /expiresAt/);
  assert.match(handler, /grantedByAdminUid:\s*adminUid/);
  assert.match(handler, /sourceCommercialRequestId:\s*requestId/);
  assert.match(handler, /\{\s*merge:\s*false\s*\}/);
});

test("approval expiry is derived exactly from approved fixed duration", () => {
  const handler = approvalHandlerSource();

  assert.match(
    source,
    /const allowedCommercialApprovalDurations = new Set<number>\(\[1,\s*3,\s*7,\s*10\]\)/,
  );
  assert.match(
    handler,
    /now\.toMillis\(\)\s*\+\s*durationDays\s*\*\s*24\s*\*\s*60\s*\*\s*60\s*\*\s*1000/,
  );
  assert.match(handler, /Timestamp\.fromMillis/);
  assert.match(handler, /approvedDurationDays:\s*durationDays/);
});

test("approval updates access request and audit in one transaction", () => {
  const handler = approvalHandlerSource();

  assert.match(handler, /firestore\.runTransaction/);
  assert.match(handler, /transaction\.set\(/);
  assert.match(handler, /transaction\.update\(requestRef/);
  assert.match(handler, /transaction\.create\(auditRef/);
  assert.match(handler, /status:\s*"approved"/);
  assert.match(
    handler,
    /eventType:\s*"commercial_access_request_approved"/,
  );
  assert.match(handler, /sourceCommercialRequestId:\s*requestId/);
  assert.match(handler, /durationDays/);
});

test("ordinary user request creation cannot grant access", () => {
  const requestStart = source.indexOf(
    "export const requestCommercialAccess = onCall",
  );
  const approvalStart = source.indexOf(
    "export const approveCommercialAccessRequest = onCall",
  );

  assert.ok(requestStart >= 0);
  assert.ok(approvalStart > requestStart);

  const requestHandler = source.slice(requestStart, approvalStart);

  assert.match(requestHandler, /status:\s*"pending"/);
  assert.doesNotMatch(requestHandler, /licenseStatus:\s*"active"/);
  assert.doesNotMatch(requestHandler, /subscriptionStatus:\s*"active"/);
  assert.doesNotMatch(requestHandler, /billingState:\s*"paid"/);
  assert.doesNotMatch(requestHandler, /commercialAccessV2/);
});

test("client approval payload cannot override canonical grant facts", () => {
  const handler = approvalHandlerSource();

  assert.match(handler, /payload\.requestId/);
  assert.match(handler, /payload\.durationDays/);
  assert.doesNotMatch(handler, /payload\.planId/);
  assert.doesNotMatch(handler, /payload\.monthlyPriceInr/);
  assert.doesNotMatch(handler, /payload\.licenseStatus/);
  assert.doesNotMatch(handler, /payload\.subscriptionStatus/);
  assert.doesNotMatch(handler, /payload\.billingState/);
  assert.doesNotMatch(handler, /payload\.deviceAllowance/);
  assert.doesNotMatch(handler, /payload\.grantedEntitlements/);
  assert.doesNotMatch(handler, /payload\.expiresAt/);
});
