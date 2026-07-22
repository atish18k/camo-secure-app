import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const source = fs.readFileSync(
  path.resolve(process.cwd(), "src", "index.ts"),
  "utf8",
);

test("approval resolves target user from the pending request", () => {
  assert.match(
    source,
    /\.collection\("commercialAccessRequestsV1"\)[\s\S]*?\.doc\(requestId\)/,
  );
  assert.match(source, /pending\.userId !== requestId/);
  assert.match(
    source,
    /\.collection\("users"\)[\s\S]*?\.doc\(pending\.userId\)/,
  );
  assert.doesNotMatch(
    source,
    /approveCommercialAccessRequest[\s\S]*?payload\.userId/,
  );
});

test("approval updates access request and audit in one transaction", () => {
  assert.match(
    source,
    /export const approveCommercialAccessRequest = onCall[\s\S]*?firestore\.runTransaction/,
  );
  assert.match(source, /status: "approved"/);
  assert.match(
    source,
    /eventType: "commercial_access_request_approved"/,
  );
  assert.match(source, /sourceCommercialRequestId: requestId/);
});

test("ordinary user request creation cannot grant access", () => {
  assert.match(
    source,
    /export const requestCommercialAccess = onCall/,
  );
  assert.match(source, /status: "pending"/);
    const requestStart = source.indexOf(
    "export const requestCommercialAccess = onCall",
  );
  const approvalStart = source.indexOf(
    "export const approveCommercialAccessRequest = onCall",
  );

  assert.ok(requestStart >= 0);
  assert.ok(approvalStart > requestStart);

  const requestHandlerSource = source.slice(requestStart, approvalStart);

  assert.doesNotMatch(requestHandlerSource, /licenseStatus:\s*"active"/);
  assert.doesNotMatch(requestHandlerSource, /subscriptionStatus:\s*"active"/);
  assert.doesNotMatch(requestHandlerSource, /billingState:\s*"paid"/);
  assert.doesNotMatch(requestHandlerSource, /commercialAccessV2/);
});