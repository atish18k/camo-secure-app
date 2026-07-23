import {CamoMessageValidityV1} from "./message_policy_types";

export type CamoOperationType = "encode" | "decode";

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
  readonly commercialAccessBypass?: boolean;
  readonly requestedAt: string;
  readonly serverReceivedAt: string;
  readonly payloadDigest: string;
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

export interface CamoKmsAuthorizationDecision {
  readonly permitted: boolean;
  readonly releaseId: string;
  readonly keyReference: string;
  readonly reasonCode: string;
}