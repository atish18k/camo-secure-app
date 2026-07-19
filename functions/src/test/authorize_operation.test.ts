import assert from "node:assert/strict";
import test from "node:test";
import {createFailClosedDenial, parseAuthorizationInput} from "../authorization_contract";

function createValidInput(): Record<string, unknown> {
  return {requestId: "request-001", operationId: "operation-001",
    userId: "user-001", deviceId: "device-001",
    payloadDigest: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", operationType: "encode",
    keyPurpose: "messageEncryption", keyScope: "message",
    requestedAt: "2026-07-13T12:00:00.000Z", pairId: "pair-001",
    messageId: "message-001", messageValidity: "five_minutes",
    oneTimeView: false, requiredEntitlements: ["baseEncoding"],
    attributes: {source: "workspace"}};
}

test("valid encode policy request is parsed and normalized", () => {
  const result = parseAuthorizationInput(createValidInput());
  assert.equal(result.messageId, "message-001");
  assert.equal(result.messageValidity, "five_minutes");
  assert.equal(result.oneTimeView, false);
});

test("encode requires message identity and validity", () => {
  const missingMessage = createValidInput(); delete missingMessage.messageId;
  assert.throws(() => parseAuthorizationInput(missingMessage), /requires pairId and messageId/);
  const missingValidity = createValidInput(); delete missingValidity.messageValidity;
  assert.throws(() => parseAuthorizationInput(missingValidity), /messageValidity/);
});

test("one-time view remains fail-closed disabled", () => {
  const input = createValidInput(); input.oneTimeView = true;
  assert.throws(() => parseAuthorizationInput(input), /not activated/);
});

test("decode requires messageId and rejects encode-only policy fields", () => {
  const input = createValidInput(); input.operationType = "decode";
  input.keyPurpose = "messageDecryption"; delete input.messageValidity;
  delete input.oneTimeView;
  assert.equal(parseAuthorizationInput(input).messageId, "message-001");
  input.messageValidity = "five_minutes";
  assert.throws(() => parseAuthorizationInput(input), /rejects encode policy fields/);
});

test("request with empty device identifier is rejected", () => {
  const input = createValidInput(); input.deviceId = " ";
  assert.throws(() => parseAuthorizationInput(input), /deviceId/);
});

test("unsupported operation type is rejected", () => {
  const input = createValidInput(); input.operationType = "exportAllKeys";
  assert.throws(() => parseAuthorizationInput(input), /operationType/);
});

test("authorization result remains fail closed", () => {
  const denial = createFailClosedDenial(() => new Date("2026-07-13T12:30:00.000Z"));
  assert.equal(denial.authorized, false);
  assert.equal(denial.reasonCode, "production_authorization_not_activated");
});
