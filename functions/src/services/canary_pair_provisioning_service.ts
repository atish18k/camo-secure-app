import {FieldValue, Firestore} from "firebase-admin/firestore";
export const canaryPair = Object.freeze({
  pairId: "ea002-seq15-controlled-canary-v1",
  participantUserIds: ["mP72XpT0v8gq2USSXsFmSg8aFSw1", "sXl0ci9cO4WYJWxJmzycAznvBwz2"] as const,
  requestedBy: "mP72XpT0v8gq2USSXsFmSg8aFSw1",
});
export async function provisionControlledCanaryPair(firestore: Firestore, provisionerUid: string) {
  if (provisionerUid !== "52WuVLqvCCYf89WApttFctDb1hc2") throw new Error("Unexpected canary provisioner.");
  const ref = firestore.doc("pairings/" + canaryPair.pairId);
  return firestore.runTransaction(async (tx) => {
    if ((await tx.get(ref)).exists) throw new Error("Canary pair already exists; replay rejected.");
    tx.create(ref, {schemaVersion: 1, pairId: canaryPair.pairId,
      participantUserIds: [...canaryPair.participantUserIds], status: "active",
      requestedBy: canaryPair.requestedBy, canary: true, provisionedBy: provisionerUid,
      createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
      acceptedAt: FieldValue.serverTimestamp()});
    return Object.freeze({pairId: canaryPair.pairId, status: "active" as const});
  });
}