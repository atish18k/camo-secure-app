import assert from "node:assert/strict";
import test from "node:test";

import {
  createFailClosedDenial,
  parseAuthorizationInput,
} from "../authorization_contract";

function createValidInput(): Record<string, unknown> {
  return {
    requestId: "request-001",
    operationId: "operation-001",
    userId: "user-001",
    deviceId: "device-001",
    operationType: "encode",
    keyPurpose: "messageEncryption",
    keyScope: "message",
    requestedAt: "2026-07-13T12:00:00.000Z",
    pairId: "pair-001",
    requiredEntitlements: ["baseEncoding"],
    attributes: {
      source: "workspace",
    },
  };
}

test("valid encode request is parsed and normalized", () => {
  const result = parseAuthorizationInput(createValidInput());

  assert.equal(result.requestId, "request-001");
  assert.equal(result.operationType, "encode");
  assert.equal(result.pairId, "pair-001");
  assert.deepEqual(result.requiredEntitlements, ["baseEncoding"]);
});

test("decode request without messageId is rejected", () => {
  const input = createValidInput();

  input.operationType = "decode";
  input.keyPurpose = "messageDecryption";

  assert.throws(
    () => parseAuthorizationInput(input),
    /Decode authorization requires messageId/,
  );
});

test("request with empty device identifier is rejected", () => {
  const input = createValidInput();

  input.deviceId = " ";

  assert.throws(
    () => parseAuthorizationInput(input),
    /deviceId/,
  );
});

test("unsupported operation type is rejected", () => {
  const input = createValidInput();

  input.operationType = "exportAllKeys";

  assert.throws(
    () => parseAuthorizationInput(input),
    /operationType/,
  );
});

test("authorization result remains fail closed", () => {
  const denial = createFailClosedDenial(
    () => new Date("2026-07-13T12:30:00.000Z"),
  );

  assert.equal(denial.authorized, false);
  assert.equal(
    denial.reasonCode,
    "production_authorization_not_activated",
  );
  assert.equal(denial.serverTime, "2026-07-13T12:30:00.000Z");
});