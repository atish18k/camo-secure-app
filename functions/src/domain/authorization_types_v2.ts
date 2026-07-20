export const camoAuthorizationSchemaVersionV2 = 2 as const;

export const camoAuthorizationCanonicalizationVersionV2 =
  "CAMO_AUTHORIZATION_V2" as const;

export const camoServerShareVersionV1 = 1 as const;
export const camoServerShareByteLength = 32 as const;

export interface CamoUnsignedAuthorizationResponseV2 {
  readonly schemaVersion: typeof camoAuthorizationSchemaVersionV2;
  readonly canonicalizationVersion:
    typeof camoAuthorizationCanonicalizationVersionV2;
  readonly requestId: string;
  readonly authorized: true;
  readonly authorizationId: string;
  readonly operationId: string;
  readonly challengeId: string;
  readonly userId: string;
  readonly deviceId: string;
  readonly pairId: string;
  readonly messageId: string;
  readonly payloadDigest: string;
  readonly keyReleaseId: string;
  readonly keyReference: string;
  readonly sessionId: string;
  readonly serverShareId: string;
  readonly serverShareVersion: typeof camoServerShareVersionV1;
  readonly serverShareBase64: string;
  readonly serverShareExpiresAt: string;
  readonly issuedAt: string;
  readonly expiresAt: string;
  readonly reasonCode: string;
}

export interface CamoSignedAuthorizationResponseV2
  extends CamoUnsignedAuthorizationResponseV2 {
  readonly signatureAlgorithm: "EC_SIGN_P256_SHA256";
  readonly signatureEncoding: "DER_BASE64";
  readonly signingKeyId: string;
  readonly signature: string;
}

export interface CamoGeneratedServerShareV1 {
  readonly shareId: string;
  readonly operationId: string;
  readonly version: typeof camoServerShareVersionV1;
  readonly bytes: Uint8Array;
  readonly base64: string;
  readonly expiresAt: string;
}