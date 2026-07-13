import {
  CamoKmsAuthorizationDecision,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  CamoKmsAuthorizationPort,
} from "../domain/authorization_ports";

export class FailClosedCamoKmsAuthorizationService
  implements CamoKmsAuthorizationPort {
  async authorizeKeyRelease(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoKmsAuthorizationDecision> {
    void context;

    return Object.freeze({
      permitted: false,
      releaseId: "",
      keyReference: "",
      reasonCode: "production_kms_unavailable",
    });
  }
}