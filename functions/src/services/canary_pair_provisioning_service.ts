import {FieldValue, Firestore} from "firebase-admin/firestore";

export const canaryPair = Object.freeze({
  schemaVersion: 1 as const,
  pairId: "ea002-seq15-controlled-canary-v1",
  participantUserIds: [
    "LsSzAKvXZcUKzzkyFZLqN2fgdkm2",
    "dQMhOUtVwjcl17KQgIa52pbETOn1",
  ] as const,
  requestedBy: "dQMhOUtVwjcl17KQgIa52pbETOn1",
  status: "active" as const,
  canary: true as const,
});

export type ControlledCanaryProvisioningResult = Readonly<{
  pairId: string;
  status: "active";
  outcome: "created" | "already_provisioned";
}>;

function isExactExistingCanaryPair(
  data: Readonly<Record<string, unknown>> | undefined,
): boolean {
  if (data === undefined) return false;

  const participants = data.participantUserIds;
  return (
    data.schemaVersion === canaryPair.schemaVersion &&
    data.pairId === canaryPair.pairId &&
    Array.isArray(participants) &&
    participants.length === canaryPair.participantUserIds.length &&
    participants.every(
      (value, index) => value === canaryPair.participantUserIds[index],
    ) &&
    data.status === canaryPair.status &&
    data.requestedBy === canaryPair.requestedBy &&
    data.canary === true &&
    data.provisionedBy === canaryPair.requestedBy
  );
}

export async function provisionControlledCanaryPair(
  firestore: Firestore,
  provisionerUid: string,
): Promise<ControlledCanaryProvisioningResult> {
  if (provisionerUid !== canaryPair.requestedBy) {
    throw new Error("Unexpected canary provisioner.");
  }

  const pairReference = firestore.doc(`pairings/${canaryPair.pairId}`);
  const auditReference = firestore.doc(
    `canarySeedAudits/${canaryPair.pairId}`,
  );

  return firestore.runTransaction(async (transaction) => {
    const pairSnapshot = await transaction.get(pairReference);

    if (pairSnapshot.exists) {
      if (!isExactExistingCanaryPair(pairSnapshot.data())) {
        throw new Error(
          "Existing canary pair does not match the locked seed contract.",
        );
      }

      return Object.freeze({
        pairId: canaryPair.pairId,
        status: canaryPair.status,
        outcome: "already_provisioned" as const,
      });
    }

    transaction.create(pairReference, {
      schemaVersion: canaryPair.schemaVersion,
      pairId: canaryPair.pairId,
      participantUserIds: [...canaryPair.participantUserIds],
      status: canaryPair.status,
      requestedBy: canaryPair.requestedBy,
      canary: canaryPair.canary,
      provisionedBy: provisionerUid,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      acceptedAt: FieldValue.serverTimestamp(),
    });

    transaction.create(auditReference, {
      schemaVersion: 1,
      eventType: "controlled_canary_seed_created",
      pairId: canaryPair.pairId,
      participantUserIds: [...canaryPair.participantUserIds],
      requestedBy: canaryPair.requestedBy,
      provisionedBy: provisionerUid,
      outcome: "created",
      createdAt: FieldValue.serverTimestamp(),
    });

    return Object.freeze({
      pairId: canaryPair.pairId,
      status: canaryPair.status,
      outcome: "created" as const,
    });
  });
}
