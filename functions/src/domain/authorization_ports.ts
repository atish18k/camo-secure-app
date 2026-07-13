import {
  CamoDomainDecision,
  CamoKmsAuthorizationDecision,
  CamoReplayArtifact,
  CamoServerAuthorizationContext,
  CamoSignedAuthorizationResponse,
  CamoUnsignedAuthorizationResponse,
} from "./authorization_types";

export interface CamoUserAuthorizationPort {
  validateUser(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision>;
}

export interface CamoDeviceAuthorizationPort {
  validateDevice(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision>;
}

export interface CamoPairAuthorizationPort {
  validatePair(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision>;
}

export interface CamoPolicyAuthorizationPort {
  evaluatePolicy(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision>;
}

export interface CamoRiskAuthorizationPort {
  evaluateRisk(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision>;
}

export interface CamoEntitlementAuthorizationPort {
  validateEntitlements(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision>;
}

export interface CamoKmsAuthorizationPort {
  authorizeKeyRelease(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoKmsAuthorizationDecision>;
}

export interface CamoAuthorizationResponseSigner {
  sign(
    response: CamoUnsignedAuthorizationResponse,
  ): Promise<CamoSignedAuthorizationResponse>;
}

export interface CamoAuthorizationReplayStore {
  consume(artifact: CamoReplayArtifact): Promise<boolean>;
}