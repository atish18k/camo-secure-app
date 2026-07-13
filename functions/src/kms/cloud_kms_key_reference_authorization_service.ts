import {
  CamoKmsAuthorizationPort,
} from "../domain/authorization_ports";
import {
  CamoKmsAuthorizationDecision,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  CamoCloudKmsKeyVersionInspector,
} from "./cloud_kms_key_version_inspector";

export class CloudKmsCamoKeyReferenceAuthorizationService
  implements CamoKmsAuthorizationPort {
  constructor(
    private readonly inspector:
      CamoCloudKmsKeyVersionInspector,
    private readonly keyVersionName:
      string,
    private readonly releaseIdGenerator:
      () => string,
  ) {}

  async authorizeKeyRelease(
    context:
      CamoServerAuthorizationContext,
  ): Promise<CamoKmsAuthorizationDecision> {
    if (
      context.operationId.trim().length === 0 ||
      context.deviceId.trim().length === 0 ||
      (context.pairId?.trim().length ?? 0) === 0
    ) {
      return this.denied(
        "cloud_kms_context_invalid",
      );
    }

    const readiness =
      await this.inspector.inspect(
        this.keyVersionName,
      );

    if (!readiness.ready) {
      return this.denied(
        readiness.reasonCode,
      );
    }

    const releaseId =
      this.releaseIdGenerator().trim();

    if (releaseId.length === 0) {
      return this.denied(
        "cloud_kms_release_identifier_invalid",
      );
    }

    return Object.freeze({
      permitted: true,
      releaseId,
      keyReference:
        readiness.keyVersionName,
      reasonCode:
        "cloud_kms_key_reference_authorized",
    });
  }

  private denied(
    reasonCode: string,
  ): CamoKmsAuthorizationDecision {
    return Object.freeze({
      permitted: false,
      releaseId: "",
      keyReference: "",
      reasonCode,
    });
  }
}