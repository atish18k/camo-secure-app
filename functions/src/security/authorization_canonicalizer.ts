import {
  CamoUnsignedAuthorizationResponse,
} from "../domain/authorization_types";

function normalizeOptional(value: string | undefined): string {
  return value?.trim() ?? "";
}

export function canonicalizeAuthorizationResponse(
  response: CamoUnsignedAuthorizationResponse,
): string {
  return [
    `schemaVersion=${response.schemaVersion}`,
    `canonicalizationVersion=${response.canonicalizationVersion}`,
    `requestId=${response.requestId.trim()}`,
    `authorized=${response.authorized ? "true" : "false"}`,
    `authorizationId=${response.authorizationId.trim()}`,
    `operationId=${response.operationId.trim()}`,
    `challengeId=${response.challengeId.trim()}`,
    `userId=${response.userId.trim()}`,
    `deviceId=${response.deviceId.trim()}`,
    `pairId=${normalizeOptional(response.pairId)}`,
    `messageId=${normalizeOptional(response.messageId)}`,
    `keyReleaseId=${response.keyReleaseId.trim()}`,
    `keyReference=${response.keyReference.trim()}`,
    `sessionId=${response.sessionId.trim()}`,
    `issuedAt=${response.issuedAt.trim()}`,
    `expiresAt=${response.expiresAt.trim()}`,
    `reasonCode=${response.reasonCode.trim()}`,
  ].join("\n");
}