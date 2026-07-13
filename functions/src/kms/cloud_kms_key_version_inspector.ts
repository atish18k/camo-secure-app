import {
  CamoCloudKmsClient,
} from "./camo_cloud_kms_client";
import {
  normalizeCloudKmsKeyVersionName,
} from "./cloud_kms_key_version_name";

export interface CamoCloudKmsKeyReadiness {
  readonly ready: boolean;
  readonly reasonCode: string;
  readonly keyVersionName: string;
  readonly algorithm: string;
  readonly protectionLevel: string;
}

const supportedSigningAlgorithms = new Set([
  "EC_SIGN_P256_SHA256",
  "RSA_SIGN_PSS_2048_SHA256",
  "RSA_SIGN_PSS_3072_SHA256",
  "RSA_SIGN_PSS_4096_SHA256",
]);

export class CamoCloudKmsKeyVersionInspector {
  constructor(
    private readonly client: CamoCloudKmsClient,
  ) {}

  async inspect(
    keyVersionName: string,
  ): Promise<CamoCloudKmsKeyReadiness> {
    let normalizedName: string;

    try {
      normalizedName =
        normalizeCloudKmsKeyVersionName(
          keyVersionName,
        );
    } catch {
      return this.denied(
        "cloud_kms_key_version_name_invalid",
        "",
        "",
        "",
      );
    }

    try {
      const version =
        await this.client.getKeyVersion(
          normalizedName,
        );

      if (version.name !== normalizedName) {
        return this.denied(
          "cloud_kms_key_version_binding_mismatch",
          normalizedName,
          version.algorithm,
          version.protectionLevel,
        );
      }

      if (version.state !== "ENABLED") {
        return this.denied(
          "cloud_kms_key_version_not_enabled",
          normalizedName,
          version.algorithm,
          version.protectionLevel,
        );
      }

      if (
        !supportedSigningAlgorithms.has(
          version.algorithm,
        )
      ) {
        return this.denied(
          "cloud_kms_signing_algorithm_unsupported",
          normalizedName,
          version.algorithm,
          version.protectionLevel,
        );
      }

      return Object.freeze({
        ready: true,
        reasonCode:
          "cloud_kms_key_version_ready",
        keyVersionName: normalizedName,
        algorithm: version.algorithm,
        protectionLevel:
          version.protectionLevel,
      });
    } catch {
      return this.denied(
        "cloud_kms_key_version_unavailable",
        normalizedName,
        "",
        "",
      );
    }
  }

  private denied(
    reasonCode: string,
    keyVersionName: string,
    algorithm: string,
    protectionLevel: string,
  ): CamoCloudKmsKeyReadiness {
    return Object.freeze({
      ready: false,
      reasonCode,
      keyVersionName,
      algorithm,
      protectionLevel,
    });
  }
}