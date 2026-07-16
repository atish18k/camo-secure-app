import assert from "node:assert/strict";
import test from "node:test";
import {CamoCanonicalMessagePolicyV1} from "../domain/message_policy_types";
import {FirestoreCamoMessagePolicyStore} from "../infrastructure/firestore_camo_message_policy_store";

const policy: CamoCanonicalMessagePolicyV1 = Object.freeze({
  schemaVersion: 1, messageId: "message-1", pairId: "pair-1",
  senderUserId: "user-1", senderDeviceId: "device-1", state: "active",
  validity: "five_minutes", oneTimeView: true, policyVersion: 1,
  requiredPolicyVersion: 1, createdAt: "2026-07-17T00:00:00.000Z",
  updatedAt: "2026-07-17T00:00:00.000Z",
  expiresAt: "2026-07-17T00:05:00.000Z",
});

function fakeFirestore(options: Readonly<{
  exists?: boolean; state?: string; fail?: boolean;
}> = {}) {
  const created: Array<Record<string, unknown>> = [];
  const updated: Array<Record<string, unknown>> = [];
  let transactionCalls = 0;
  const firestore = {
    collection: (collectionPath: string) => ({
      doc: (id: string) => ({collectionPath, id}),
    }),
    runTransaction: async (work: (transaction: unknown) => Promise<boolean>) => {
      transactionCalls++;
      if (options.fail === true) throw new Error("transaction_failed");
      const transaction = {
        get: async () => ({
          exists: options.exists === true,
          get: (field: string) => field === "state" ? options.state : undefined,
        }),
        create: (_reference: unknown, value: Record<string, unknown>) => {
          created.push(value);
        },
        update: (_reference: unknown, value: Record<string, unknown>) => {
          updated.push(value);
        },
      };
      return work(transaction);
    },
  };
  return {firestore, created, updated, transactionCalls: () => transactionCalls};
}

test("atomically creates canonical policy only when absent", async () => {
  const fake = fakeFirestore();
  const store = new FirestoreCamoMessagePolicyStore(fake.firestore as never);
  assert.equal(await store.createIfAbsent(policy), true);
  assert.equal(fake.created.length, 1);
  assert.equal(fake.created[0].messageId, "message-1");
  assert.equal(fake.created[0].state, "active");
  assert.equal(fake.updated.length, 0);
});

test("duplicate create is rejected without write", async () => {
  const fake = fakeFirestore({exists: true});
  const store = new FirestoreCamoMessagePolicyStore(fake.firestore as never);
  assert.equal(await store.createIfAbsent(policy), false);
  assert.equal(fake.created.length, 0);
});

test("active policy transitions once to terminal state", async () => {
  const fake = fakeFirestore({exists: true, state: "active"});
  const store = new FirestoreCamoMessagePolicyStore(fake.firestore as never);
  assert.equal(await store.transitionIfActive({messageId: "message-1",
    nextState: "consumed", transitionedAt: "2026-07-17T00:01:00.000Z"}), true);
  assert.equal(fake.updated.length, 1);
  assert.equal(fake.updated[0].state, "consumed");
  assert.equal(fake.updated[0].consumed, true);
});

test("terminal state rejects replay without write", async () => {
  const fake = fakeFirestore({exists: true, state: "consumed"});
  const store = new FirestoreCamoMessagePolicyStore(fake.firestore as never);
  assert.equal(await store.transitionIfActive({messageId: "message-1",
    nextState: "revoked", transitionedAt: "2026-07-17T00:02:00.000Z"}), false);
  assert.equal(fake.updated.length, 0);
});

test("malformed policy fails before transaction", async () => {
  const fake = fakeFirestore();
  const store = new FirestoreCamoMessagePolicyStore(fake.firestore as never);
  assert.equal(await store.createIfAbsent({...policy, messageId: "bad/id"}), false);
  assert.equal(fake.transactionCalls(), 0);
});

test("Firestore transaction failure fails closed", async () => {
  const fake = fakeFirestore({fail: true});
  const store = new FirestoreCamoMessagePolicyStore(fake.firestore as never);
  assert.equal(await store.createIfAbsent(policy), false);
  assert.equal(await store.transitionIfActive({messageId: "message-1",
    nextState: "blocked", transitionedAt: "2026-07-17T00:02:00.000Z"}), false);
});
