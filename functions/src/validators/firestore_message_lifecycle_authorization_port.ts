import {
  CamoDomainDecision,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  camoFirestorePathsV1,
  camoMessageLifecycleStatusesV1,
} from "../contracts/canonical_firestore_security_contract_v1";
import {
  CamoAuthorizationDocument,
  CamoAuthorizationDocumentReader,
  readOptionalBoolean,
  readRequiredString,
} from "../infrastructure/authorization_document_reader";

function denied(reasonCode: string): CamoDomainDecision {
  return Object.freeze({allowed: false, reasonCode});
}

function readRequiredInteger(
  document: CamoAuthorizationDocument,
  field: string,
): number | null {
  const value = document[field];
  return typeof value === "number" && Number.isInteger(value) ? value : null;
}

function readTimestampMilliseconds(value: unknown): number | null {
  if (typeof value === "string") {
    const parsed = Date.parse(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  if (value instanceof Date) return value.getTime();
  if (typeof value === "object" && value !== null && "toDate" in value) {
    try {
      const date = (value as {toDate(): unknown}).toDate();
      return date instanceof Date ? date.getTime() : null;
    } catch {
      return null;
    }
  }
  return null;
}

export class FirestoreCamoMessageLifecycleAuthorizationPort {
  constructor(
    private readonly reader: CamoAuthorizationDocumentReader,
    private readonly clock: () => Date = () => new Date(),
  ) {}

  async validateMessageLifecycle(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    if (context.operationType !== "decode") {
      return Object.freeze({
        allowed: true,
        reasonCode: "server_message_lifecycle_not_required_for_encode",
      });
    }
    const messageId = context.messageId?.trim();
    const pairId = context.pairId?.trim();
    if (!messageId || !pairId) return denied("server_message_binding_missing");

    const document = await this.reader.readDocument(
      camoFirestorePathsV1.messagePolicy(messageId),
    );
    if (document === null) return denied("server_message_policy_not_found");

    const schemaVersion = readRequiredInteger(document, "schemaVersion");
    const storedMessageId = readRequiredString(document, "messageId");
    const storedPairId = readRequiredString(document, "pairId");
    const senderUserId = readRequiredString(document, "senderUserId");
    const senderDeviceId = readRequiredString(document, "senderDeviceId");
    const state = readRequiredString(document, "state");
    const validity = readRequiredString(document, "validity");
    const oneTimeView = readOptionalBoolean(document, "oneTimeView");
    const policyVersion = readRequiredInteger(document, "policyVersion");
    const requiredPolicyVersion = readRequiredInteger(
      document,
      "requiredPolicyVersion",
    );

    if (
      schemaVersion !== 1 || storedMessageId !== messageId ||
      storedPairId !== pairId || senderUserId === null ||
      senderDeviceId === null || state === null ||
      !camoMessageLifecycleStatusesV1.includes(
        state as typeof camoMessageLifecycleStatusesV1[number],
      ) || validity === null || oneTimeView === null ||
      policyVersion === null || requiredPolicyVersion === null ||
      policyVersion !== requiredPolicyVersion
    ) return denied("server_message_policy_invalid");

    if (state !== "active") return denied(`server_message_${state}`);
    for (const flag of ["expired", "revoked", "consumed", "deleted", "burned", "blocked"]) {
      if (readOptionalBoolean(document, flag) === true) {
        return denied(`server_message_${flag}`);
      }
    }

    const expiresAt = document.expiresAt;
    if (validity === "unlimited") {
      if (expiresAt !== undefined && expiresAt !== null) {
        return denied("server_message_expiry_invalid");
      }
    } else {
      const expiry = readTimestampMilliseconds(expiresAt);
      if (expiry === null) return denied("server_message_expiry_invalid");
      if (this.clock().getTime() >= expiry) return denied("server_message_expired");
    }
    return Object.freeze({allowed: true, reasonCode: "server_message_lifecycle_valid"});
  }
}