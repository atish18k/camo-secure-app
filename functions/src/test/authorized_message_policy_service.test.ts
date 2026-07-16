import assert from "node:assert/strict";
import test from "node:test";
import {
  CamoAuthorizationExecutionResult,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  CamoCanonicalMessagePolicyV1,
  CamoMessagePolicyStore,
} from "../domain/message_policy_types";
import {AuthorizedMessagePolicyService} from "../services/authorized_message_policy_service";
import {CamoMessagePolicyLifecycleService} from "../services/message_policy_lifecycle_service";

const context: CamoServerAuthorizationContext = Object.freeze({
  requestId: "request-1", operationId: "operation-1", userId: "user-1",
  deviceId: "device-1", operationType: "encode", pairId: "pair-1",
  messageId: "message-1", messageValidity: "five_minutes", oneTimeView: false,
  keyPurpose: "messageEncryption", keyScope: "message",
  requiredEntitlements: ["baseEncoding"],
  requestedAt: "2026-07-17T00:00:00.000Z",
  serverReceivedAt: "2026-07-17T00:00:01.000Z",
});

class Store implements CamoMessagePolicyStore {
  created: CamoCanonicalMessagePolicyV1[] = [];
  constructor(private readonly accept = true) {}
  async createIfAbsent(policy: CamoCanonicalMessagePolicyV1): Promise<boolean> {
    if (!this.accept) return false;
    this.created.push(policy); return true;
  }
  async transitionIfActive(): Promise<boolean> { return false; }
}

const allowed: CamoAuthorizationExecutionResult = Object.freeze({
  authorized: true, reasonCode: "server_authorization_granted",
  signedResponse: {} as never,
});

function service(result: CamoAuthorizationExecutionResult, store: Store) {
  return new AuthorizedMessagePolicyService(
    {authorize: async () => result},
    new CamoMessagePolicyLifecycleService(
      store,
      () => new Date("2026-07-17T00:00:02.000Z"),
    ),
  );
}

test("authorized encode creates bound policy before returning allow", async () => {
  const store = new Store();
  const result = await service(allowed, store).authorize(context);
  assert.equal(result, allowed);
  assert.equal(store.created.length, 1);
  assert.equal(store.created[0].messageId, "message-1");
  assert.equal(store.created[0].senderUserId, "user-1");
  assert.equal(store.created[0].oneTimeView, false);
});

test("authorization denial never creates policy", async () => {
  const store = new Store();
  const denial = Object.freeze({authorized: false, reasonCode: "denied"});
  const result = await service(denial, store).authorize(context);
  assert.equal(result.authorized, false);
  assert.equal(store.created.length, 0);
});

test("duplicate policy creation fails closed", async () => {
  const result = await service(allowed, new Store(false)).authorize(context);
  assert.deepEqual(result, {
    authorized: false,
    reasonCode: "server_message_policy_creation_denied",
  });
});

test("one-time view cannot bypass disabled contract", async () => {
  const store = new Store();
  const result = await service(allowed, store).authorize({
    ...context, oneTimeView: true as never,
  });
  assert.equal(result.authorized, false);
  assert.equal(result.reasonCode, "server_encode_message_policy_invalid");
  assert.equal(store.created.length, 0);
});

test("decode authorization does not create policy", async () => {
  const store = new Store();
  const result = await service(allowed, store).authorize({
    ...context, operationType: "decode", messageValidity: undefined,
    oneTimeView: undefined, keyPurpose: "messageDecryption",
  });
  assert.equal(result, allowed);
  assert.equal(store.created.length, 0);
});
