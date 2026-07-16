import {FieldValue, Firestore} from "firebase-admin/firestore";
export const canaryPair = Object.freeze({
  pairId: "ea002-seq15-controlled-canary-v1",
  participantUserIds: ["LsSzAKvXZcUKzzkyFZLqN2fgdkm2", "dQMhOUtVwjcl17KQgIa52pbETOn1"] as const,
  requestedBy: "dQMhOUtVwjcl17KQgIa52pbETOn1",
});
export async function provisionControlledCanaryPair(firestore: Firestore, provisionerUid: string) {
  if (provisionerUid !== canaryPair.requestedBy) throw new Error("Unexpected canary provisioner.");
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