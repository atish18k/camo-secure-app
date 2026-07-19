import assert from "node:assert/strict";
import test from "node:test";
import {AuthorizedMessagePolicyService} from "../services/authorized_message_policy_service";

test("message-policy service activation gate fails closed", async () => {
  let authorizerCalls = 0; let lifecycleCalls = 0;
  const service = new AuthorizedMessagePolicyService(
    {authorize: async () => {authorizerCalls++; return {
      authorized: false, reasonCode: "unexpected",
    };}},
    {create: async () => {lifecycleCalls++; throw new Error("unexpected");},
      transition: async () => {lifecycleCalls++; throw new Error("unexpected");}} as never,
    {isMessagePolicyMutationEnabled: () => false},
  );
  const result = await service.authorize({
    requestId: "r", operationId: "o", userId: "u", deviceId: "d",
    payloadDigest: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    operationType: "encode", pairId: "p", messageId: "m",
    messageValidity: "five_minutes", oneTimeView: false,
    keyPurpose: "messageEncryption", keyScope: "message",
    requiredEntitlements: ["baseEncoding"], requestedAt: "2026-07-17T00:00:00.000Z",
    serverReceivedAt: "2026-07-17T00:00:01.000Z",
  });
  assert.equal(result.reasonCode, "server_message_policy_mutation_not_activated");
  assert.equal(authorizerCalls, 0); assert.equal(lifecycleCalls, 0);
});