import {
  DocumentData,
  DocumentSnapshot,
  FieldValue,
  Firestore,
} from "firebase-admin/firestore";

export const canaryPair = Object.freeze({
  schemaVersion: 1 as const,
  pairId: "ea002-seq15-controlled-canary-v1",
  participantUserIds: [
    "LsSzAKvXZcUKzzkyFZLqN2fgdkm2",
    "dQMhOUtVwjcl17KQgIa52pbETOn1",
  ] as const,
  requestedBy: "dQMhOUtVwjcl17KQgIa52pbETOn1",
  status: "active" as const,
});

export type CanaryPairProvisioningResult = Readonly<{
  pairId: string;
  status: "active";
  outcome: "created" | "already_provisioned";
}>;

function isExactCanaryPair(
  snapshot: DocumentSnapshot<DocumentData>,
): boolean {
  if (!snapshot.exists) return false;

  const data = snapshot.data();
  if (data === undefined) return false;

  const participantUserIds = data.participantUserIds;
  if (!Array.isArray(participantUserIds)) return false;

  return (
    data.schemaVersion === canaryPair.schemaVersion &&
    data.pairId === canaryPair.pairId &&
    participantUserIds.length === canaryPair.participantUserIds.length &&
    participantUserIds.every(
      (value: unknown, index: number) =>
        value === canaryPair.participantUserIds[index],
    ) &&
    data.status === canaryPair.status &&
    data.requestedBy === canaryPair.requestedBy &&
    data.canary === true &&
    data.provisionedBy === canaryPair.requestedBy
  );
}

function createCanonicalAudit(
  provisionerUid: string,
): Readonly<Record<string, unknown>> {
  return Object.freeze({
    schemaVersion: canaryPair.schemaVersion,
    pairId: canaryPair.pairId,
    participantUserIds: [...canaryPair.participantUserIds],
    requestedBy: canaryPair.requestedBy,
    provisionedBy: provisionerUid,
    status: canaryPair.status,
    canary: true,
    outcome: "created",
    createdAt: FieldValue.serverTimestamp(),
  });
}

export async function provisionControlledCanaryPair(
  firestore: Firestore,
  provisionerUid: string,
): Promise<CanaryPairProvisioningResult> {
  if (provisionerUid !== canaryPair.requestedBy) {
    throw new Error("Unexpected canary provisioner.");
  }

  const pairReference = firestore.doc(
    `pairings/${canaryPair.pairId}`,
  );
  const auditReference = firestore.doc(
    `canarySeedAudits/${canaryPair.pairId}`,
  );

  return firestore.runTransaction(async (transaction) => {
    const pairSnapshot = await transaction.get(pairReference);
    const auditSnapshot = await transaction.get(auditReference);

    if (pairSnapshot.exists) {
      if (!isExactCanaryPair(pairSnapshot)) {
        throw new Error(
          "Existing canary pair does not match the locked seed contract.",
        );
      }

      if (!auditSnapshot.exists) {
        transaction.create(
          auditReference,
          createCanonicalAudit(provisionerUid),
        );
      }

      return Object.freeze({
        pairId: canaryPair.pairId,
        status: canaryPair.status,
        outcome: "already_provisioned" as const,
      });
    }

    if (auditSnapshot.exists) {
      throw new Error(
        "Canary audit exists without the locked canonical pair.",
      );
    }

    transaction.create(pairReference, {
      schemaVersion: canaryPair.schemaVersion,
      pairId: canaryPair.pairId,
      participantUserIds: [...canaryPair.participantUserIds],
      status: canaryPair.status,
      requestedBy: canaryPair.requestedBy,
      canary: true,
      provisionedBy: provisionerUid,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      acceptedAt: FieldValue.serverTimestamp(),
    });

    transaction.create(
      auditReference,
      createCanonicalAudit(provisionerUid),
    );

    return Object.freeze({
      pairId: canaryPair.pairId,
      status: canaryPair.status,
      outcome: "created" as const,
    });
  });
}
