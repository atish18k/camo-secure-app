import assert from "node:assert/strict";
import test from "node:test";
import {
  CamoAuthorizationExecutionResult,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  CamoCanonicalMessagePolicyV1,
  CamoMessagePolicyStore,
  CamoMessageTerminalStateV1,
} from "../domain/message_policy_types";
import {AuthorizedMessagePolicyService} from "../services/authorized_message_policy_service";
import {CamoMessagePolicyLifecycleService} from "../services/message_policy_lifecycle_service";

const encodeContext: CamoServerAuthorizationContext = Object.freeze({
  requestId: "request-1", operationId: "operation-1", userId: "user-1",
  deviceId: "device-1", operationType: "encode", pairId: "pair-1",
  messageId: "message-1", messageValidity: "five_minutes", oneTimeView: false,
  keyPurpose: "messageEncryption", keyScope: "message",
  requiredEntitlements: ["baseEncoding"],
  requestedAt: "2026-07-17T00:00:00.000Z",
  serverReceivedAt: "2026-07-17T00:00:01.000Z",
});

const decodeContext: CamoServerAuthorizationContext = Object.freeze({
  ...encodeContext, operationType: "decode", messageValidity: undefined,
  oneTimeView: undefined, keyPurpose: "messageDecryption",
  requiredEntitlements: ["baseDecoding"],
});

class Store implements CamoMessagePolicyStore {
  created: CamoCanonicalMessagePolicyV1[] = [];
  state: "active" | CamoMessageTerminalStateV1 = "active";
  constructor(private readonly acceptCreate = true) {}
  async createIfAbsent(policy: CamoCanonicalMessagePolicyV1): Promise<boolean> {
    if (!this.acceptCreate || this.created.length > 0) return false;
    this.created.push(policy); return true;
  }
  async transitionIfActive(input: Readonly<{
    messageId: string; nextState: CamoMessageTerminalStateV1; transitionedAt: string;
  }>): Promise<boolean> {
    assert.equal(input.messageId, "message-1");
    if (this.state !== "active") return false;
    this.state = input.nextState; return true;
  }
}

const allowed: CamoAuthorizationExecutionResult = Object.freeze({
  authorized: true, reasonCode: "server_authorization_granted",
  signedResponse: {} as never,
});

function service(options: Readonly<{
  result?: CamoAuthorizationExecutionResult; store?: Store;
  enabled?: boolean; authorizerCalls?: {value: number};
}> = {}) {
  const store = options.store ?? new Store();
  return {
    store,
    value: new AuthorizedMessagePolicyService(
      {authorize: async () => {
        if (options.authorizerCalls) options.authorizerCalls.value++;
        return options.result ?? allowed;
      }},
      new CamoMessagePolicyLifecycleService(
        store, () => new Date("2026-07-17T00:00:02.000Z"),
      ),
      {isMessagePolicyMutationEnabled: () => options.enabled === true},
    ),
  };
}

test("activation OFF denies before authorizer and mutation", async () => {
  const calls = {value: 0}; const current = service({authorizerCalls: calls});
  const result = await current.value.authorize(encodeContext);
  assert.deepEqual(result, {authorized: false,
    reasonCode: "server_message_policy_mutation_not_activated"});
  assert.equal(calls.value, 0); assert.equal(current.store.created.length, 0);
});

test("authorized signed encode creates canonical active policy", async () => {
  const current = service({enabled: true});
  const result = await current.value.authorize(encodeContext);
  assert.equal(result, allowed); assert.equal(current.store.created.length, 1);
  assert.equal(current.store.created[0].messageId, "message-1");
  assert.equal(current.store.created[0].oneTimeView, false);
});

test("authorization denial never creates policy", async () => {
  const denial = Object.freeze({authorized: false, reasonCode: "denied"});
  const current = service({enabled: true, result: denial});
  assert.equal((await current.value.authorize(encodeContext)).authorized, false);
  assert.equal(current.store.created.length, 0);
});

test("duplicate encode policy creation fails closed", async () => {
  const current = service({enabled: true, store: new Store(false)});
  assert.deepEqual(await current.value.authorize(encodeContext), {
    authorized: false, reasonCode: "server_message_policy_creation_denied",
  });
});

test("one-time view remains disabled before policy mutation", async () => {
  const current = service({enabled: true});
  const result = await current.value.authorize({
    ...encodeContext, oneTimeView: true as never,
  });
  assert.equal(result.reasonCode, "server_encode_message_policy_invalid");
  assert.equal(current.store.created.length, 0);
});

test("decode reservation is atomic single winner", async () => {
  const store = new Store(); const current = service({enabled: true, store});
  assert.equal(await current.value.authorize(decodeContext), allowed);
  assert.equal(store.state, "consumed");
  const replay = await current.value.authorize(decodeContext);
  assert.deepEqual(replay, {authorized: false,
    reasonCode: "server_decode_reservation_denied"});
});