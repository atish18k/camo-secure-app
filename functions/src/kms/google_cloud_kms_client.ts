import {
  KeyManagementServiceClient,
  protos,
} from "@google-cloud/kms";

import {
  CamoCloudKmsClient,
  CamoCloudKmsKeyVersionResponse,
  CamoCloudKmsPublicKeyResponse,
  CamoCloudKmsSignRequest,
  CamoCloudKmsSignResponse,
} from "./camo_cloud_kms_client";

type AsymmetricSignRequest =
  protos.google.cloud.kms.v1.IAsymmetricSignRequest;

type CloudKmsBinaryValue =
  string |
  Uint8Array |
  Buffer;

export function normalizeCloudKmsBinaryValue(
  value: CloudKmsBinaryValue,
): Uint8Array {
  if (typeof value === "string") {
    const normalized = value.trim();

    if (normalized.length === 0) {
      throw new Error(
        "cloud_kms_binary_value_empty",
      );
    }

    const decoded = Buffer.from(normalized, "base64");

    if (decoded.length === 0) {
      throw new Error(
        "cloud_kms_binary_value_invalid",
      );
    }

    return Uint8Array.from(decoded);
  }

  if (value.length === 0) {
    throw new Error(
      "cloud_kms_binary_value_empty",
    );
  }

  return Uint8Array.from(value);
}

export class GoogleCloudCamoKmsClient
  implements CamoCloudKmsClient {
  constructor(
    private readonly client =
      new KeyManagementServiceClient(),
  ) {}

  async asymmetricSign(
    request: CamoCloudKmsSignRequest,
  ): Promise<CamoCloudKmsSignResponse> {
    const apiRequest: AsymmetricSignRequest = {
      name: request.name,
      digest: {
        sha256: Buffer.from(request.digest.sha256),
      },
      digestCrc32c: {
        value: request.digestCrc32c,
      },
    };

    const result =
      await this.client.asymmetricSign(apiRequest);

    const response = result[0];
    const responseName = response.name?.trim() ?? "";
    const signature = response.signature;

    if (
      responseName.length === 0 ||
      signature === null ||
      signature === undefined
    ) {
      throw new Error(
        "cloud_kms_sign_response_incomplete",
      );
    }

    const signatureBytes =
      normalizeCloudKmsBinaryValue(signature);

    return Object.freeze({
      name: responseName,
      signature: signatureBytes,
      signatureCrc32c:
        response.signatureCrc32c?.toString() ?? "",
      verifiedDigestCrc32c:
        response.verifiedDigestCrc32c === true,
    });
  }

  async getPublicKey(
    keyVersionName: string,
  ): Promise<CamoCloudKmsPublicKeyResponse> {
    const result = await this.client.getPublicKey({
      name: keyVersionName,
    });

    const response = result[0];

    const responseName = response.name?.trim() ?? "";
    const pem = response.pem?.trim() ?? "";

    if (
      responseName.length === 0 ||
      pem.length === 0
    ) {
      throw new Error(
        "cloud_kms_public_key_response_incomplete",
      );
    }

    return Object.freeze({
      name: responseName,
      pem,
      algorithm: String(response.algorithm ?? ""),
      pemCrc32c:
        response.pemCrc32c?.toString() ?? "",
    });
  }

  async getKeyVersion(
    keyVersionName: string,
  ): Promise<CamoCloudKmsKeyVersionResponse> {
    const result =
      await this.client.getCryptoKeyVersion({
        name: keyVersionName,
      });

    const response = result[0];
    const responseName = response.name?.trim() ?? "";

    if (responseName.length === 0) {
      throw new Error(
        "cloud_kms_key_version_response_incomplete",
      );
    }

    return Object.freeze({
      name: responseName,
      state: String(response.state ?? ""),
      algorithm: String(response.algorithm ?? ""),
      protectionLevel: String(
        response.protectionLevel ?? "",
      ),
    });
  }
}