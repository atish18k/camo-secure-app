import assert from "node:assert/strict";
import test from "node:test";
import {camoMessagePolicyTransitionsV2} from "../domain/message_policy_v2_types";
import {FirestoreCamoRiskAuthorizationPort} from "../validators/firestore_risk_authorization_port";

const context = {requestId: "r", operationId: "o", userId: "u", deviceId: "d", operationType: "encode" as const,
  pairId: "p", messageId: "m", keyPurpose: "messageEncryption", keyScope: "message",
  requiredEntitlements: ["baseEncoding"], requestedAt: "2026-07-19T00:00:00.000Z", serverReceivedAt: "2026-07-19T00:00:01.000Z"};
const valid = {schemaVersion: 1, operationId: "o", userId: "u", deviceId: "d", pairId: "p", messageId: "m",
  decision: "allow", permitsOperation: true, createdAt: "2026-07-18T23:59:00.000Z", expiresAt: "2026-07-19T00:01:00.000Z"};
class Reader { constructor(private readonly value: Readonly<Record<string, unknown>>) {} async readDocument() { return this.value; } }

test("V2 permits only pending to active blocked or expired", () => {
  assert.deepEqual([...camoMessagePolicyTransitionsV2.pending], ["active", "blocked", "expired"]);
  assert.equal(camoMessagePolicyTransitionsV2.blocked.length, 0);
});
test("risk decision requires exact bindings and live server interval", async () => {
  const clock = () => new Date("2026-07-19T00:00:00.000Z");
  assert.equal((await new FirestoreCamoRiskAuthorizationPort(new Reader(valid), clock).evaluateRisk(context)).allowed, true);
  for (const bad of [{...valid, userId: "other"}, {...valid, messageId: "other"}, {...valid, expiresAt: "2026-07-19T00:00:00.000Z"}]) {
    assert.equal((await new FirestoreCamoRiskAuthorizationPort(new Reader(bad), clock).evaluateRisk(context)).allowed, false);
  }
});
