import assert from "node:assert/strict";
import test from "node:test";
import {
  CamoCanonicalMessagePolicyV1,
  CamoMessagePolicyStore,
  CamoMessageTerminalStateV1,
} from "../domain/message_policy_types";
import {CamoMessagePolicyLifecycleService} from "../services/message_policy_lifecycle_service";

class Store implements CamoMessagePolicyStore {
  value: CamoCanonicalMessagePolicyV1 | null = null;
  state: "active" | CamoMessageTerminalStateV1 | null = null;
  async createIfAbsent(policy: CamoCanonicalMessagePolicyV1): Promise<boolean> {
    if (this.value !== null) return false;
    this.value = policy; this.state = "active"; return true;
  }
  async transitionIfActive(input: Readonly<{messageId: string; nextState: CamoMessageTerminalStateV1; transitionedAt: string;}>): Promise<boolean> {
    if (this.value?.messageId !== input.messageId || this.state !== "active") return false;
    assert.match(input.transitionedAt, /Z$/); this.state = input.nextState; return true;
  }
}
const input = {messageId: "message-1", pairId: "pair-1", senderUserId: "user-1",
  senderDeviceId: "device-1", validity: "five_minutes" as const, oneTimeView: true};

test("creates canonical policy with exact five-minute server expiry", async () => {
  const store = new Store();
  const service = new CamoMessagePolicyLifecycleService(store, () => new Date("2026-07-17T00:00:00.000Z"));
  const policy = await service.create(input);
  assert.equal(policy.schemaVersion, 1); assert.equal(policy.state, "active");
  assert.equal(policy.expiresAt, "2026-07-17T00:05:00.000Z");
  assert.equal(policy.senderUserId, "user-1");
});

test("unlimited policy omits expiresAt", async () => {
  const policy = await new CamoMessagePolicyLifecycleService(new Store()).create({...input, validity: "unlimited"});
  assert.equal("expiresAt" in policy, false);
});

test("duplicate creation is rejected", async () => {
  const service = new CamoMessagePolicyLifecycleService(new Store());
  await service.create(input);
  await assert.rejects(() => service.create(input), /message_policy_replay_rejected/);
});

test("transition is one-way and replay is rejected", async () => {
  const store = new Store(); const service = new CamoMessagePolicyLifecycleService(store);
  await service.create(input); await service.transition("message-1", "consumed");
  assert.equal(store.state, "consumed");
  await assert.rejects(() => service.transition("message-1", "revoked"), /transition_rejected/);
});

test("invalid identifiers fail before store mutation", async () => {
  const store = new Store(); const service = new CamoMessagePolicyLifecycleService(store);
  await assert.rejects(() => service.create({...input, messageId: "bad/id"}), /invalid_message_policy_message_id/);
  assert.equal(store.value, null);
});