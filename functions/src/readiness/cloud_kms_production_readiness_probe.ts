import {
  CamoCloudKmsKeyVersionInspector,
} from "../kms/cloud_kms_key_version_inspector";
import {
  CloudKmsCamoPublicKeyMetadataProvider,
} from "../kms/cloud_kms_public_key_metadata_provider";

export interface CamoCloudKmsProductionReadiness {
  readonly ready: boolean;
  readonly reasonCode: string;
  readonly keyVersionReady: boolean;
  readonly publicKeyIntegrityReady: boolean;
}

export class CamoCloudKmsProductionReadinessProbe {
  constructor(
    private readonly keyVersionName: string,
    private readonly inspector:
      CamoCloudKmsKeyVersionInspector,
    private readonly publicKeyProvider:
      CloudKmsCamoPublicKeyMetadataProvider,
  ) {}

  async evaluate():
    Promise<CamoCloudKmsProductionReadiness> {
    try {
      const keyReadiness =
        await this.inspector.inspect(
          this.keyVersionName,
        );

      if (!keyReadiness.ready) {
        return Object.freeze({
          ready: false,
          reasonCode:
            keyReadiness.reasonCode,
          keyVersionReady: false,
          publicKeyIntegrityReady: false,
        });
      }

      await this.publicKeyProvider.getMetadata(
        this.keyVersionName,
      );

      return Object.freeze({
        ready: true,
        reasonCode:
          "cloud_kms_production_ready",
        keyVersionReady: true,
        publicKeyIntegrityReady: true,
      });
    } catch {
      return Object.freeze({
        ready: false,
        reasonCode:
          "cloud_kms_readiness_verification_failed",
        keyVersionReady: false,
        publicKeyIntegrityReady: false,
      });
    }
  }
}