import assert from "node:assert/strict";
import test from "node:test";
import {Firestore} from "firebase-admin/firestore";

import {
  canaryPair,
  provisionControlledCanaryPair,
} from "../services/canary_pair_provisioning_service";

type StoredDocument = Readonly<Record<string, unknown>>;
type Reference = Readonly<{path: string}>;

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

function createMemoryFirestore(
  initialDocuments: Readonly<Record<string, StoredDocument>> = {},
): Readonly<{
  firestore: Firestore;
  documents: Map<string, StoredDocument>;
  createCalls: string[];
}> {
  const documents = new Map<string, StoredDocument>(
    Object.entries(initialDocuments),
  );
  const createCalls: string[] = [];

  const firestore = {
    doc: (path: string): Reference => Object.freeze({path}),
    runTransaction: async (
      callback: (transaction: {
        get: (reference: Reference) => Promise<{
          exists: boolean;
          data: () => StoredDocument | undefined;
        }>;
        create: (
          reference: Reference,
          data: StoredDocument,
        ) => void;
      }) => unknown,
    ) => callback({
      get: async (reference: Reference) => ({
        exists: documents.has(reference.path),
        data: () => documents.get(reference.path),
      }),
      create: (
        reference: Reference,
        data: StoredDocument,
      ) => {
        if (documents.has(reference.path)) {
          throw new Error(`Document already exists: ${reference.path}`);
        }
        createCalls.push(reference.path);
        documents.set(reference.path, data);
      },
    }),
  } as unknown as Firestore;

  return Object.freeze({
    firestore,
    documents,
    createCalls,
  });
}

test("canary contract is fixed and canonical", () => {
  assert.equal(canaryPair.participantUserIds.length, 2);
  assert.ok(
    canaryPair.participantUserIds[0] <
      canaryPair.participantUserIds[1],
  );
  assert.ok(
    canaryPair.participantUserIds.includes(
      canaryPair.requestedBy,
    ),
  );
  assert.equal(
    canaryPair.pairId,
    "ea002-seq15-controlled-canary-v1",
  );
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
  const state = createMemoryFirestore();

  const result = await provisionControlledCanaryPair(
    state.firestore,
    canaryPair.requestedBy,
  );

  assert.deepEqual(result, {
    pairId: canaryPair.pairId,
    status: "active",
    outcome: "created",
  });

  assert.deepEqual(state.createCalls, [
    `pairings/${canaryPair.pairId}`,
    `canarySeedAudits/${canaryPair.pairId}`,
  ]);

  assert.equal(
    state.documents.has(`pairings/${canaryPair.pairId}`),
    true,
  );
  assert.equal(
    state.documents.has(
      `canarySeedAudits/${canaryPair.pairId}`,
    ),
    true,
  );
});

test("existing exact pair and audit perform zero writes", async () => {
  const pairPath = `pairings/${canaryPair.pairId}`;
  const auditPath =
    `canarySeedAudits/${canaryPair.pairId}`;

  const state = createMemoryFirestore({
    [pairPath]: exactExistingPair(),
    [auditPath]: Object.freeze({
      schemaVersion: canaryPair.schemaVersion,
      pairId: canaryPair.pairId,
      canary: true,
    }),
  });

  const result = await provisionControlledCanaryPair(
    state.firestore,
    canaryPair.requestedBy,
  );

  assert.deepEqual(result, {
    pairId: canaryPair.pairId,
    status: "active",
    outcome: "already_provisioned",
  });
  assert.deepEqual(state.createCalls, []);
});

test("existing exact pair repairs missing audit exactly once", async () => {
  const pairPath = `pairings/${canaryPair.pairId}`;
  const auditPath =
    `canarySeedAudits/${canaryPair.pairId}`;

  const pairDocument = exactExistingPair();
  const state = createMemoryFirestore({
    [pairPath]: pairDocument,
  });

  const firstResult = await provisionControlledCanaryPair(
    state.firestore,
    canaryPair.requestedBy,
  );

  assert.deepEqual(firstResult, {
    pairId: canaryPair.pairId,
    status: "active",
    outcome: "already_provisioned",
  });
  assert.deepEqual(state.createCalls, [auditPath]);
  assert.strictEqual(
    state.documents.get(pairPath),
    pairDocument,
  );
  assert.equal(state.documents.has(auditPath), true);

  const writesAfterRepair = state.createCalls.length;

  const secondResult = await provisionControlledCanaryPair(
    state.firestore,
    canaryPair.requestedBy,
  );

  assert.deepEqual(secondResult, {
    pairId: canaryPair.pairId,
    status: "active",
    outcome: "already_provisioned",
  });
  assert.equal(
    state.createCalls.length,
    writesAfterRepair,
  );
  assert.strictEqual(
    state.documents.get(pairPath),
    pairDocument,
  );
});

test("existing mismatched pair fails closed without writes", async () => {
  const pairPath = `pairings/${canaryPair.pairId}`;

  const state = createMemoryFirestore({
    [pairPath]: Object.freeze({
      ...exactExistingPair(),
      participantUserIds: [
        "attacker",
        canaryPair.requestedBy,
      ],
    }),
  });

  await assert.rejects(
    () => provisionControlledCanaryPair(
      state.firestore,
      canaryPair.requestedBy,
    ),
    /does not match the locked seed contract/,
  );

  assert.deepEqual(state.createCalls, []);
});

test("orphan audit fails closed without pair creation", async () => {
  const auditPath =
    `canarySeedAudits/${canaryPair.pairId}`;

  const state = createMemoryFirestore({
    [auditPath]: Object.freeze({
      schemaVersion: canaryPair.schemaVersion,
      pairId: canaryPair.pairId,
      canary: true,
    }),
  });

  await assert.rejects(
    () => provisionControlledCanaryPair(
      state.firestore,
      canaryPair.requestedBy,
    ),
    /audit exists without the locked canonical pair/,
  );

  assert.deepEqual(state.createCalls, []);
});
