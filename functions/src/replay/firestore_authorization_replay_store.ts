import {
  FieldValue,
  Firestore,
  Timestamp,
} from "firebase-admin/firestore";

import {
  CamoAuthorizationReplayStore,
} from "../domain/authorization_ports";
import {
  CamoReplayArtifact,
} from "../domain/authorization_types";

export class FirestoreCamoAuthorizationReplayStore
  implements CamoAuthorizationReplayStore {
  constructor(
    private readonly firestore: Firestore,
    private readonly collectionPath =
      "enterpriseAuthorizationConsumptions",
    private readonly clock: () => Date = () => new Date(),
  ) {}

  async consume(artifact: CamoReplayArtifact): Promise<boolean> {
    if (!this.isValidArtifact(artifact)) {
      return false;
    }

    const now = this.clock();

    if (now.getTime() >= Date.parse(artifact.expiresAt)) {
      return false;
    }

    const documentReference = this.firestore
      .collection(this.collectionPath)
      .doc(artifact.authorizationId);

    try {
      return await this.firestore.runTransaction(async (transaction) => {
        const existing = await transaction.get(documentReference);

        if (existing.exists) {
          return false;
        }

        transaction.create(documentReference, {
          authorizationId: artifact.authorizationId,
          operationId: artifact.operationId,
          challengeId: artifact.challengeId,
          userId: artifact.userId,
          issuedAt: Timestamp.fromDate(new Date(artifact.issuedAt)),
          expiresAt: Timestamp.fromDate(new Date(artifact.expiresAt)),
          consumedAt: FieldValue.serverTimestamp(),
        });

        return true;
      });
    } catch {
      return false;
    }
  }

  private isValidArtifact(artifact: CamoReplayArtifact): boolean {
    return (
      artifact.authorizationId.trim().length > 0 &&
      artifact.operationId.trim().length > 0 &&
      artifact.challengeId.trim().length > 0 &&
      artifact.userId.trim().length > 0 &&
      Number.isFinite(Date.parse(artifact.issuedAt)) &&
      Number.isFinite(Date.parse(artifact.expiresAt)) &&
      Date.parse(artifact.issuedAt) < Date.parse(artifact.expiresAt)
    );
  }
}