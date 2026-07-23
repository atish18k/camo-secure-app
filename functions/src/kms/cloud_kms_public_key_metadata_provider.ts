import {
  CamoCloudKmsClient,
} from "./camo_cloud_kms_client";
import {
  CamoCrc32cCalculator,
} from "./camo_crc32c_calculator";
import {
  cloudKmsSigningKeyId,
  normalizeCloudKmsKeyVersionName,
} from "./cloud_kms_key_version_name";

export interface CamoPublicVerificationKeyMetadata {
  readonly signingKeyId: string;
  readonly keyVersionName: string;
  readonly algorithm: string;
  readonly publicKeyPem: string;
  readonly publicKeyPemCrc32c: string;
}

export class CloudKmsCamoPublicKeyMetadataProvider {
  constructor(
    private readonly client: CamoCloudKmsClient,
    private readonly crc32c: CamoCrc32cCalculator,
  ) {}

  async getMetadata(
    keyVersionName: string,
  ): Promise<CamoPublicVerificationKeyMetadata> {
    const normalized =
      normalizeCloudKmsKeyVersionName(
        keyVersionName,
      );

    const response =
      await this.client.getPublicKey(
        normalized,
      );

    if (
      response.name !== normalized ||
      response.pem.trim().length === 0 ||
      response.algorithm.trim().length === 0 ||
      response.pemCrc32c.trim().length === 0
    ) {
      throw new Error(
        "cloud_kms_public_key_metadata_invalid",
      );
    }

    const pemBytes = Uint8Array.from(
      Buffer.from(response.pem, "utf8"),
    );

    if (
      !this.crc32c.verify(
        pemBytes,
        response.pemCrc32c,
      )
    ) {
      throw new Error(
        "cloud_kms_public_key_integrity_failed",
      );
    }

    return Object.freeze({
      signingKeyId:
        cloudKmsSigningKeyId(normalized),
      keyVersionName: normalized,
      algorithm: response.algorithm,
      publicKeyPem: response.pem,
      publicKeyPemCrc32c:
        response.pemCrc32c,
    });
  }
}