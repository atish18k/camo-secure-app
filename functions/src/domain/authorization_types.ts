export const camoAuthorizationSchemaVersion = 1 as const;

export const camoAuthorizationCanonicalizationVersion =
  "CAMO_AUTHORIZATION_V1" as const;

export const camoAuthorizationSignatureAlgorithm =
  "EC_SIGN_P256_SHA256" as const;

export const camoAuthorizationSignatureEncoding =
  "DER_BASE64" as const;

export type CamoOperationType = "encode" | "decode";

import {CamoMessageValidityV1} from "./message_policy_types";

export interface CamoServerAuthorizationContext {
  readonly requestId: string;
  readonly operationId: string;
  readonly userId: string;
  readonly deviceId: string;
  readonly operationType: CamoOperationType;
  readonly pairId?: string;
  readonly messageId?: string;
  readonly messageValidity?: CamoMessageValidityV1;
  readonly oneTimeView?: false;
  readonly keyPurpose: string;
  readonly keyScope: string;
  readonly requiredEntitlements: readonly string[];
  readonly requestedAt: string;
  readonly serverReceivedAt: string;
}

export interface CamoDomainDecision {
  readonly allowed: boolean;
  readonly reasonCode: string;
}

export interface CamoReplayArtifact {
  readonly authorizationId: string;
  readonly operationId: string;
  readonly challengeId: string;
  readonly userId: string;
  readonly issuedAt: string;
  readonly expiresAt: string;
}

export interface CamoUnsignedAuthorizationResponse {
  readonly schemaVersion:
    typeof camoAuthorizationSchemaVersion;
  readonly canonicalizationVersion:
    typeof camoAuthorizationCanonicalizationVersion;
  readonly requestId: string;
  readonly authorized: boolean;
  readonly authorizationId: string;
  readonly operationId: string;
  readonly challengeId: string;
  readonly userId: string;
  readonly deviceId: string;
  readonly pairId?: string;
  readonly messageId?: string;
  readonly keyReleaseId: string;
  readonly keyReference: string;
  readonly sessionId: string;
  readonly issuedAt: string;
  readonly expiresAt: string;
  readonly reasonCode: string;
}

export interface CamoSignedAuthorizationResponse
  extends CamoUnsignedAuthorizationResponse {
  readonly signatureAlgorithm:
    typeof camoAuthorizationSignatureAlgorithm;
  readonly signatureEncoding:
    typeof camoAuthorizationSignatureEncoding;
  readonly signingKeyId: string;
  readonly signature: string;
}

export interface CamoKmsAuthorizationDecision {
  readonly permitted: boolean;
  readonly releaseId: string;
  readonly keyReference: string;
  readonly reasonCode: string;
}

export interface CamoAuthorizationExecutionResult {
  readonly authorized: boolean;
  readonly reasonCode: string;
  readonly signedResponse?: CamoSignedAuthorizationResponse;
}

