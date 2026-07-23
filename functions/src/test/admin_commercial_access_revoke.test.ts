import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";

const source = fs.readFileSync(
  path.resolve(process.cwd(), "src", "index.ts"),
  "utf8",
);

function revokeSource(): string {
  const start = source.indexOf("export const revokeCommercialAccess = onCall");
  const end = source.indexOf("const authorizationOrchestrator =", start);
  assert.ok(start >= 0);
  assert.ok(end > start);
  return source.slice(start, end);
}

test("commercial revoke remains locked-admin only", () => {
  const revoke = revokeSource();
  assert.match(revoke, /const adminUid = assertLockedAdmin\(request\)/);
  assert.match(revoke, /enforceAppCheck:\s*true/);
  assert.match(revoke, /consumeAppCheckToken:\s*true/);
});

test("commercial revoke resolves exact server-owned target", () => {
  const revoke = revokeSource();
  assert.match(revoke, /payload\.userId/);
  assert.match(revoke, /collection\("users"\)/);
  assert.match(revoke, /collection\("commercialAccessV2"\)/);
  assert.match(revoke, /\.doc\("current"\)/);
  assert.doesNotMatch(revoke, /payload\.licenseStatus/);
  assert.doesNotMatch(revoke, /payload\.subscriptionStatus/);
  assert.doesNotMatch(revoke, /payload\.billingState/);
});

test("commercial revoke updates access request and audit atomically", () => {
  const revoke = revokeSource();
  assert.match(revoke, /firestore\.runTransaction/);
  assert.match(revoke, /licenseStatus:\s*"revoked"/);
  assert.match(revoke, /subscriptionStatus:\s*"revoked"/);
  assert.match(revoke, /billingState:\s*"revoked"/);
  assert.match(revoke, /revokedAt:\s*now/);
  assert.match(revoke, /revokedByAdminUid:\s*adminUid/);
  assert.match(revoke, /status:\s*"revoked"/);
  assert.match(revoke, /transaction\.create\(auditRef/);
  assert.match(revoke, /eventType:\s*"commercial_access_revoked"/);
});

test("active access listing is admin-only and expiry-aware", () => {
  const start = source.indexOf(
    "export const listActiveCommercialAccess = onCall",
  );
  const end = source.indexOf(
    "export const revokeCommercialAccess = onCall",
    start,
  );
  assert.ok(start >= 0);
  assert.ok(end > start);
  const listing = source.slice(start, end);

  assert.match(listing, /assertLockedAdmin\(request\)/);
  assert.match(listing, /licenseStatus !== "active"/);
  assert.match(listing, /subscriptionStatus !== "active"/);
  assert.match(listing, /billingState !== "paid"/);
  assert.match(listing, /expiresAt instanceof Timestamp/);
});
