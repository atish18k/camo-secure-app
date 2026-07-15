import assert from "node:assert/strict";
import test from "node:test";

import {
  camoDeviceStateTransitionsV1,
  camoFirestoreContractVersion,
  camoFirestoreDocumentsV1,
  camoFirestorePathsV1,
  camoPairStateTransitionsV1,
} from "../contracts/canonical_firestore_security_contract_v1";

test("canonical Firestore contract is locked to Version 1", () => {
  assert.equal(camoFirestoreContractVersion, 1);
});

test("canonical authorization document paths match server usage", () => {
  assert.equal(camoFirestorePathsV1.user("user-a"), "users/user-a");
  assert.equal(
    camoFirestorePathsV1.device("user-a", "device-a"),
    "users/user-a/devices/device-a",
  );
  assert.equal(
    camoFirestorePathsV1.pairing("pair-a"),
    "pairings/pair-a",
  );
  assert.equal(
    camoFirestorePathsV1.enterprisePolicy(),
    "enterprisePolicies/global",
  );
  assert.equal(
    camoFirestorePathsV1.commercialAccess("user-a"),
    "users/user-a/commercialAccess/current",
  );
  assert.equal(
    camoFirestorePathsV1.riskDecision("operation-a"),
    "enterpriseRiskDecisions/operation-a",
  );
  assert.equal(
    camoFirestorePathsV1.authorizationConsumption(
      "authorization-a",
    ),
    "enterpriseAuthorizationConsumptions/authorization-a",
  );
});

test("canonical device records are server-only", () => {
  const device = camoFirestoreDocumentsV1.device;

  assert.equal(device.authority, "server_only");
  assert.ok(device.requiredFields.includes("status"));
  assert.ok(device.requiredFields.includes("publicKey"));
  assert.ok(device.requiredFields.includes("keyVersion"));
  assert.ok(device.legacyCompatibilityFields.includes("approved"));
  assert.ok(device.legacyCompatibilityFields.includes("revoked"));
});

test("device registration accepts client facts but not approval", () => {
  const request =
    camoFirestoreDocumentsV1.deviceRegistrationRequest;

  assert.equal(request.authority, "client_fact");
  assert.ok(request.requiredFields.includes("status"));
  assert.ok(request.requiredFields.includes("requestedAt"));
  assert.ok(request.optionalFields.includes("resolvedBy"));
});

test("device and pair state transitions cannot self-reactivate", () => {
  assert.deepEqual(
    camoDeviceStateTransitionsV1.revoked,
    ["blacklisted"],
  );
  assert.deepEqual(
    camoDeviceStateTransitionsV1.blacklisted,
    [],
  );
  assert.deepEqual(
    camoPairStateTransitionsV1.revoked,
    [],
  );
  assert.deepEqual(
    camoPairStateTransitionsV1.blocked,
    [],
  );
});

test("invalid Firestore path segments fail closed", () => {
  assert.throws(
    () => camoFirestorePathsV1.user(""),
    /Invalid Firestore document segment/u,
  );
  assert.throws(
    () => camoFirestorePathsV1.device(
      "user-a",
      "unsafe/device",
    ),
    /Invalid Firestore document segment/u,
  );
  assert.throws(
    () => camoFirestorePathsV1.pairing(" pair/a "),
    /Invalid Firestore document segment/u,
  );
});
