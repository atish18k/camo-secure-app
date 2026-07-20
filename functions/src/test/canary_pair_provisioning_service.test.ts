import assert from "node:assert/strict";
import test from "node:test";
import {Firestore} from "firebase-admin/firestore";
import {
  canaryPair,
  provisionControlledCanaryPair,
} from "../services/canary_pair_provisioning_service";

type StoredDocument = Readonly<Record<string, unknown>>;

function exactExistingPair(): StoredDocument {
  return Object.freeze({
    schemaVersion: canaryPair.schemaVersion,
    pairId: canaryPair.pairId,
    participantUserIds: [...canaryPair.participantUserIds],
    status: canaryPair.status,
    requestedBy: canaryPair.requestedBy,
    canary: true,
    provisionedBy: canaryPair.requestedBy,
  });
}

test("canary contract is fixed and canonical", () => {
  assert.equal(canaryPair.participantUserIds.length, 2);
  assert.ok(
    canaryPair.participantUserIds[0] < canaryPair.participantUserIds[1],
  );
  assert.ok(canaryPair.participantUserIds.includes(canaryPair.requestedBy));
  assert.equal(canaryPair.pairId, "ea002-seq15-controlled-canary-v1");
});

test("wrong provisioner fails before transaction", async () => {
  let transactionCalls = 0;
  const firestore = {
    runTransaction: async () => {
      transactionCalls++;
    },
  } as unknown as Firestore;

  await assert.rejects(
    () => provisionControlledCanaryPair(firestore, "wrong"),
    /Unexpected canary provisioner/,
  );
  assert.equal(transactionCalls, 0);
});

test("creates pair and audit atomically once", async () => {
  const createdPaths: string[] = [];
  const references = new Map<string, Readonly<{path: string}>>();

  const firestore = {
    doc: (path: string) => {
      const reference = Object.freeze({path});
      references.set(path, reference);
      return reference;
    },
    runTransaction: async (
      callback: (transaction: {
        get: (
          reference: Readonly<{path: string}>,
        ) => Promise<Readonly<{
          exists: boolean;
          data: () => StoredDocument | undefined;
        }>>;
        create: (
          reference: Readonly<{path: string}>,
          value: StoredDocument,
        ) => void;
      }) => Promise<unknown>,
    ) => callback({
      get: async () => ({
        exists: false,
        data: () => undefined,
      }),
      create: (reference) => {
        createdPaths.push(reference.path);
      },
    }),
  } as unknown as Firestore;

  const result = await provisionControlledCanaryPair(
    firestore,
    canaryPair.requestedBy,
  );

  assert.deepEqual(result, {
    pairId: canaryPair.pairId,
    status: "active",
    outcome: "created",
  });
  assert.deepEqual(createdPaths, [
    `pairings/${canaryPair.pairId}`,
    `canarySeedAudits/${canaryPair.pairId}`,
  ]);
  assert.equal(references.size, 2);
});

test("exact replay is idempotent and performs no writes", async () => {
  let createCalls = 0;
  const firestore = {
    doc: (path: string) => Object.freeze({path}),
    runTransaction: async (
      callback: (transaction: {
        get: () => Promise<Readonly<{
          exists: boolean;
          data: () => StoredDocument;
        }>>;
        create: () => void;
      }) => Promise<unknown>,
    ) => callback({
      get: async () => ({
        exists: true,
        data: exactExistingPair,
      }),
      create: () => {
        createCalls++;
      },
    }),
  } as unknown as Firestore;

  const result = await provisionControlledCanaryPair(
    firestore,
    canaryPair.requestedBy,
  );

  assert.deepEqual(result, {
    pairId: canaryPair.pairId,
    status: "active",
    outcome: "already_provisioned",
  });
  assert.equal(createCalls, 0);
});

test("existing mismatched pair fails closed without writes", async () => {
  let createCalls = 0;
  const firestore = {
    doc: (path: string) => Object.freeze({path}),
    runTransaction: async (
      callback: (transaction: {
        get: () => Promise<Readonly<{
          exists: boolean;
          data: () => StoredDocument;
        }>>;
        create: () => void;
      }) => Promise<unknown>,
    ) => callback({
      get: async () => ({
        exists: true,
        data: () => ({
          ...exactExistingPair(),
          participantUserIds: ["attacker", canaryPair.requestedBy],
        }),
      }),
      create: () => {
        createCalls++;
      },
    }),
  } as unknown as Firestore;

  await assert.rejects(
    () => provisionControlledCanaryPair(
      firestore,
      canaryPair.requestedBy,
    ),
    /does not match the locked seed contract/,
  );
  assert.equal(createCalls, 0);
});
