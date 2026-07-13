import assert from "node:assert/strict";
import test from "node:test";

import {
  FirestoreCamoAuthorizationReplayStore,
} from "../replay/firestore_authorization_replay_store";

test("replay store rejects structurally invalid artifact", async () => {
  let transactionCalls = 0;

  const fakeFirestore = {
    collection: () => ({
      doc: () => ({}),
    }),
    runTransaction: async () => {
      transactionCalls++;
      return true;
    },
  };

  const store = new FirestoreCamoAuthorizationReplayStore(
    fakeFirestore as never,
    "testConsumptions",
    () => new Date("2026-07-13T12:00:00.000Z"),
  );

  const result = await store.consume({
    authorizationId: "",
    operationId: "operation-001",
    challengeId: "challenge-001",
    userId: "user-001",
    issuedAt: "2026-07-13T12:00:00.000Z",
    expiresAt: "2026-07-13T12:01:00.000Z",
  });

  assert.equal(result, false);
  assert.equal(transactionCalls, 0);
});

test("replay store rejects expired artifact", async () => {
  let transactionCalls = 0;

  const fakeFirestore = {
    collection: () => ({
      doc: () => ({}),
    }),
    runTransaction: async () => {
      transactionCalls++;
      return true;
    },
  };

  const store = new FirestoreCamoAuthorizationReplayStore(
    fakeFirestore as never,
    "testConsumptions",
    () => new Date("2026-07-13T12:02:00.000Z"),
  );

  const result = await store.consume({
    authorizationId: "authorization-001",
    operationId: "operation-001",
    challengeId: "challenge-001",
    userId: "user-001",
    issuedAt: "2026-07-13T12:00:00.000Z",
    expiresAt: "2026-07-13T12:01:00.000Z",
  });

  assert.equal(result, false);
  assert.equal(transactionCalls, 0);
});