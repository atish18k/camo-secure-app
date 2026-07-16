import {
  Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import {
  camoMessageTerminalStatesV1,
  camoMessageValiditiesV1,
  CamoCanonicalMessagePolicyV1,
  CamoMessagePolicyStore,
  CamoMessageTerminalStateV1,
} from "../domain/message_policy_types";

function validIdentifier(value: string): boolean {
  const normalized = value.trim();
  return normalized.length > 0 && !normalized.includes("/");
}

function validIsoTimestamp(value: string): boolean {
  return Number.isFinite(Date.parse(value));
}

export class FirestoreCamoMessagePolicyStore
  implements CamoMessagePolicyStore {
  constructor(
    private readonly firestore: Firestore,
    private readonly collectionPath = "messagePolicies",
  ) {}

  async createIfAbsent(
    policy: CamoCanonicalMessagePolicyV1,
  ): Promise<boolean> {
    if (!this.isValidPolicy(policy)) return false;
    const reference = this.firestore
      .collection(this.collectionPath)
      .doc(policy.messageId);

    try {
      return await this.firestore.runTransaction(async (transaction) => {
        const existing = await transaction.get(reference);
        if (existing.exists) return false;
        transaction.create(reference, {
          schemaVersion: policy.schemaVersion,
          messageId: policy.messageId,
          pairId: policy.pairId,
          senderUserId: policy.senderUserId,
          senderDeviceId: policy.senderDeviceId,
          state: policy.state,
          validity: policy.validity,
          oneTimeView: policy.oneTimeView,
          policyVersion: policy.policyVersion,
          requiredPolicyVersion: policy.requiredPolicyVersion,
          createdAt: Timestamp.fromDate(new Date(policy.createdAt)),
          updatedAt: Timestamp.fromDate(new Date(policy.updatedAt)),
          ...(policy.expiresAt === undefined ? {} : {
            expiresAt: Timestamp.fromDate(new Date(policy.expiresAt)),
          }),
        });
        return true;
      });
    } catch {
      return false;
    }
  }

  async transitionIfActive(input: Readonly<{
    messageId: string;
    nextState: CamoMessageTerminalStateV1;
    transitionedAt: string;
  }>): Promise<boolean> {
    if (
      !validIdentifier(input.messageId) ||
      !camoMessageTerminalStatesV1.includes(input.nextState) ||
      !validIsoTimestamp(input.transitionedAt)
    ) return false;

    const reference = this.firestore
      .collection(this.collectionPath)
      .doc(input.messageId);
    try {
      return await this.firestore.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(reference);
        if (!snapshot.exists || snapshot.get("state") !== "active") {
          return false;
        }
        transaction.update(reference, {
          state: input.nextState,
          [input.nextState]: true,
          updatedAt: Timestamp.fromDate(new Date(input.transitionedAt)),
          transitionedAt: Timestamp.fromDate(new Date(input.transitionedAt)),
        });
        return true;
      });
    } catch {
      return false;
    }
  }

  private isValidPolicy(policy: CamoCanonicalMessagePolicyV1): boolean {
    if (
      policy.schemaVersion !== 1 || policy.policyVersion !== 1 ||
      policy.requiredPolicyVersion !== 1 || policy.state !== "active" ||
      !camoMessageValiditiesV1.includes(policy.validity) ||
      !validIdentifier(policy.messageId) || !validIdentifier(policy.pairId) ||
      !validIdentifier(policy.senderUserId) ||
      !validIdentifier(policy.senderDeviceId) ||
      !validIsoTimestamp(policy.createdAt) ||
      !validIsoTimestamp(policy.updatedAt)
    ) return false;
    if (policy.validity === "unlimited") return policy.expiresAt === undefined;
    return policy.expiresAt !== undefined &&
      validIsoTimestamp(policy.expiresAt) &&
      Date.parse(policy.expiresAt) > Date.parse(policy.createdAt);
  }
}
