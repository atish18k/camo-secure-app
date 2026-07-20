import {
  CamoUnsignedAuthorizationResponseV2,
  camoAuthorizationCanonicalizationVersionV2,
  camoAuthorizationSchemaVersionV2,
  camoServerShareVersionV1,
} from "../domain/authorization_types_v2";

function requireCanonicalField(value: string, field: string): string {
  const normalized = value.trim();

  if (normalized.length === 0) {
    throw new Error(`${field}_required`);
  }

  if (normalized.includes("\n") || normalized.includes("\r")) {
    throw new Error(`${field}_contains_line_break`);
  }

  return normalized;
}

export function canonicalizeAuthorizationResponseV2(
  response: CamoUnsignedAuthorizationResponseV2,
): string {
  if (response.schemaVersion !== camoAuthorizationSchemaVersionV2) {
    throw new Error("authorization_schema_version_v2_required");
  }

  if (
    response.canonicalizationVersion !==
    camoAuthorizationCanonicalizationVersionV2
  ) {
    throw new Error("authorization_canonicalization_version_v2_required");
  }

  if (response.authorized !== true) {
    throw new Error("authorization_v2_grant_required");
  }

  if (response.serverShareVersion !== camoServerShareVersionV1) {
    throw new Error("server_share_version_v1_required");
  }

  return [
    `schemaVersion=${response.schemaVersion}`,
    `canonicalizationVersion=${response.canonicalizationVersion}`,
    `requestId=${requireCanonicalField(response.requestId, "request_id")}`,
    "authorized=true",
    `authorizationId=${requireCanonicalField(
      response.authorizationId,
      "authorization_id",
    )}`,
    `operationId=${requireCanonicalField(response.operationId, "operation_id")}`,
    `challengeId=${requireCanonicalField(response.challengeId, "challenge_id")}`,
    `userId=${requireCanonicalField(response.userId, "user_id")}`,
    `deviceId=${requireCanonicalField(response.deviceId, "device_id")}`,
    `pairId=${requireCanonicalField(response.pairId, "pair_id")}`,
    `messageId=${requireCanonicalField(response.messageId, "message_id")}`,
    `payloadDigest=${requireCanonicalField(
      response.payloadDigest,
      "payload_digest",
    )}`,
    `keyReleaseId=${requireCanonicalField(
      response.keyReleaseId,
      "key_release_id",
    )}`,
    `keyReference=${requireCanonicalField(
      response.keyReference,
      "key_reference",
    )}`,
    `sessionId=${requireCanonicalField(response.sessionId, "session_id")}`,
    `serverShareId=${requireCanonicalField(
      response.serverShareId,
      "server_share_id",
    )}`,
    `serverShareVersion=${response.serverShareVersion}`,
    `serverShareBase64=${requireCanonicalField(
      response.serverShareBase64,
      "server_share_base64",
    )}`,
    `serverShareExpiresAt=${requireCanonicalField(
      response.serverShareExpiresAt,
      "server_share_expires_at",
    )}`,
    `issuedAt=${requireCanonicalField(response.issuedAt, "issued_at")}`,
    `expiresAt=${requireCanonicalField(response.expiresAt, "expires_at")}`,
    `reasonCode=${requireCanonicalField(response.reasonCode, "reason_code")}`,
  ].join("\n");
}