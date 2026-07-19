import fs from "node:fs";
import path from "node:path";
import test, {after, before} from "node:test";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  collection,
  doc,
  getDoc,
  getDocs,
  limit,
  query,
  setDoc,
  updateDoc,
  where,
} from "firebase/firestore";

const projectId = "demo-camo-mp015";
const rules = fs.readFileSync(
  path.resolve(process.cwd(), "..", "firestore.rules"),
  "utf8",
);

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId,
    firestore: {rules},
  });

  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, "users/user-a"), {
      schemaVersion: 1,
      uid: "user-a",
      status: "active",
      disabled: false,
    });

    await setDoc(doc(db, "users/user-a/commercialAccessV2/current"), {
      schemaVersion: 2,
      userId: "user-a",
      planId: "camo_monthly_inr_199",
      monthlyPriceInr: 199,
      licenseStatus: "active",
      subscriptionStatus: "active",
      billingState: "paid",
      deviceAllowance: 2,
      grantedEntitlements: ["baseEncoding", "baseDecoding"],
      expiresAt: "2099-01-01T00:00:00.000Z",
    });

    await setDoc(doc(db, "pairings/pair-a-b"), {
      schemaVersion: 1,
      pairId: "pair-a-b",
      participantUserIds: ["user-a", "user-b"],
      status: "active",
    });

    for (const target of [
      "enterprisePolicies/global",
      "enterpriseRiskDecisions/op-1",
      "messagePolicies/message-1",
      "enterpriseAuthorizationConsumptions/auth-1",
    ]) {
      await setDoc(doc(db, target), {schemaVersion: 1});
    }
  });
});

after(async () => {
  await env.cleanup();
});

test("commercialAccessV2 is owner-get-only and never client writable", async () => {
  const ownerDb = env.authenticatedContext("user-a").firestore();
  const otherDb = env.authenticatedContext("user-b").firestore();
  const anonymousDb = env.unauthenticatedContext().firestore();
  const current = doc(ownerDb, "users/user-a/commercialAccessV2/current");

  await assertSucceeds(getDoc(current));
  await assertFails(
    getDoc(doc(otherDb, "users/user-a/commercialAccessV2/current")),
  );
  await assertFails(
    getDoc(doc(anonymousDb, "users/user-a/commercialAccessV2/current")),
  );
  await assertFails(
    setDoc(current, {
      schemaVersion: 2,
      userId: "user-a",
      subscriptionStatus: "active",
    }),
  );
  await assertFails(
    updateDoc(current, {billingState: "paid"}),
  );
  await assertFails(
    getDocs(collection(ownerDb, "users/user-a/commercialAccessV2")),
  );
});

test("legacy commercialAccess projection is also server-owned", async () => {
  const ownerDb = env.authenticatedContext("user-a").firestore();

  await assertFails(
    setDoc(
      doc(ownerDb, "users/user-a/commercialAccess/current"),
      {subscriptionActive: true},
    ),
  );
});

test("enterprise authority collections deny every direct client read and write", async () => {
  const authenticatedDb = env.authenticatedContext("user-a").firestore();
  const anonymousDb = env.unauthenticatedContext().firestore();

  for (const target of [
    "enterprisePolicies/global",
    "enterpriseRiskDecisions/op-1",
    "messagePolicies/message-1",
    "enterpriseAuthorizationConsumptions/auth-1",
  ]) {
    await assertFails(getDoc(doc(authenticatedDb, target)));
    await assertFails(getDoc(doc(anonymousDb, target)));
    await assertFails(
      setDoc(doc(authenticatedDb, target), {schemaVersion: 1}),
    );
  }
});

test("pairing documents are participant-readable but never client writable", async () => {
  const participantDb = env.authenticatedContext("user-a").firestore();
  const outsiderDb = env.authenticatedContext("user-c").firestore();
  const anonymousDb = env.unauthenticatedContext().firestore();

  await assertSucceeds(
    getDoc(doc(participantDb, "pairings/pair-a-b")),
  );
  await assertFails(
    getDoc(doc(outsiderDb, "pairings/pair-a-b")),
  );
  await assertFails(
    getDoc(doc(anonymousDb, "pairings/pair-a-b")),
  );
  await assertFails(
    setDoc(doc(participantDb, "pairings/pair-forged"), {
      participantUserIds: ["user-a", "user-c"],
      status: "active",
    }),
  );
});

test("device registration accepts only strict pending owner requests", async () => {
  const ownerDb = env.authenticatedContext("user-a").firestore();
  const otherDb = env.authenticatedContext("user-b").firestore();

  const valid = {
    schemaVersion: 1,
    requestId: "request-1",
    userId: "user-a",
    deviceId: "device-1",
    publicKey: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    keyVersion: 1,
    platform: "windows",
    status: "pending",
    requestedAt: "2026-07-19T23:59:59.000Z",
  };

  await assertSucceeds(
    setDoc(
      doc(ownerDb, "users/user-a/deviceRegistrationRequests/request-1"),
      valid,
    ),
  );

  await assertFails(
    setDoc(
      doc(ownerDb, "users/user-a/deviceRegistrationRequests/request-2"),
      {...valid, requestId: "request-2", status: "approved"},
    ),
  );

  await assertFails(
    setDoc(
      doc(ownerDb, "users/user-a/deviceRegistrationRequests/request-3"),
      {...valid, requestId: "request-3", unexpectedAuthority: true},
    ),
  );

  await assertFails(
    setDoc(
      doc(otherDb, "users/user-a/deviceRegistrationRequests/request-4"),
      {...valid, requestId: "request-4"},
    ),
  );
});

test("device registration cannot escalate immutable request bindings", async () => {
  const ownerDb = env.authenticatedContext("user-a").firestore();
  const request = doc(
    ownerDb,
    "users/user-a/deviceRegistrationRequests/request-update",
  );

  const valid = {
    schemaVersion: 1,
    requestId: "request-update",
    userId: "user-a",
    deviceId: "device-update",
    publicKey: "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",
    keyVersion: 1,
    platform: "windows",
    status: "pending",
    requestedAt: "2026-07-19T23:59:59.000Z",
  };

  await assertSucceeds(setDoc(request, valid));
  await assertSucceeds(
    updateDoc(request, {
      requestedAt: "2026-07-20T00:00:00.000Z",
    }),
  );
  await assertFails(
    updateDoc(request, {
      status: "approved",
    }),
  );
  await assertFails(
    updateDoc(request, {
      deviceId: "attacker-device",
    }),
  );
});

test("pairing query remains participant-bound", async () => {
  const participantDb = env.authenticatedContext("user-a").firestore();
  const anonymousDb = env.unauthenticatedContext().firestore();

  await assertSucceeds(
    getDocs(
      query(
        collection(participantDb, "pairings"),
        where("participantUserIds", "array-contains", "user-a"),
        limit(20),
      ),
    ),
  );

  await assertFails(
    getDocs(collection(participantDb, "pairings")),
  );

  await assertFails(
    getDocs(
      query(
        collection(participantDb, "pairings"),
        where("participantUserIds", "array-contains", "user-b"),
        limit(20),
      ),
    ),
  );

  await assertFails(
    getDocs(
      query(
        collection(anonymousDb, "pairings"),
        where("participantUserIds", "array-contains", "user-a"),
        limit(20),
      ),
    ),
  );
});