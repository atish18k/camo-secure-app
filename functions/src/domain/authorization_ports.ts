import {
  CamoDomainDecision,
  CamoKmsAuthorizationDecision,
  CamoReplayArtifact,
  CamoServerAuthorizationContext,
} from "./authorization_types";

export interface CamoUserAuthorizationPort {
  validateUser(context: CamoServerAuthorizationContext): Promise<CamoDomainDecision>;
}
export interface CamoDeviceAuthorizationPort {
  validateDevice(context: CamoServerAuthorizationContext): Promise<CamoDomainDecision>;
}
export interface CamoPairAuthorizationPort {
  validatePair(context: CamoServerAuthorizationContext): Promise<CamoDomainDecision>;
}
export interface CamoMessageLifecycleAuthorizationPort {
  validateMessageLifecycle(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision>;
}
export interface CamoPolicyAuthorizationPort {
  evaluatePolicy(context: CamoServerAuthorizationContext): Promise<CamoDomainDecision>;
}
export interface CamoRiskAuthorizationPort {
  evaluateRisk(context: CamoServerAuthorizationContext): Promise<CamoDomainDecision>;
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
export interface CamoAuthorizationReplayStore {
  consume(artifact: CamoReplayArtifact): Promise<boolean>;
}