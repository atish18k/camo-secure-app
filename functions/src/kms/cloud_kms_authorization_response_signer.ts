import {
  createHash,
} from "node:crypto";

import {
  CamoAuthorizationResponseSigner,
} from "../domain/authorization_ports";
import {
  camoAuthorizationSignatureAlgorithm,
  camoAuthorizationSignatureEncoding,
  CamoSignedAuthorizationResponse,
  CamoUnsignedAuthorizationResponse,
} from "../domain/authorization_types";
import {
  canonicalizeAuthorizationResponse,
} from "../security/authorization_canonicalizer";
import {
  CamoCloudKmsClient,
} from "./camo_cloud_kms_client";
import {
  cloudKmsSigningKeyId,
  normalizeCloudKmsKeyVersionName,
} from "./cloud_kms_key_version_name";

export interface CamoCrc32cCalculator {
  calculate(value: Uint8Array): string;

  verify(
    value: Uint8Array,
    expectedCrc32c: string,
  ): boolean;
}

export class CloudKmsCamoAuthorizationResponseSigner
  implements CamoAuthorizationResponseSigner {
  constructor(
    private readonly client:
      CamoCloudKmsClient,
    private readonly keyVersionName:
      string,
    private readonly crc32c:
      CamoCrc32cCalculator,
  ) {}

  async sign(
    response:
      CamoUnsignedAuthorizationResponse,
  ): Promise<CamoSignedAuthorizationResponse> {
    if (!response.authorized) {
      throw new Error(
        "cloud_kms_refused_unsigned_denial",
      );
    }

    const keyName =
      normalizeCloudKmsKeyVersionName(
        this.keyVersionName,
      );

    const canonical =
      canonicalizeAuthorizationResponse(
        response,
      );

    const digest = createHash("sha256")
      .update(canonical)
      .digest();

    const digestBytes =
      Uint8Array.from(digest);

    const result =
      await this.client.asymmetricSign({
        name: keyName,
        digest: {
          sha256: digestBytes,
        },
        digestCrc32c:
          this.crc32c.calculate(
            digestBytes,
          ),
      });

    if (
      result.name !== keyName ||
      !result.verifiedDigestCrc32c ||
      result.signature.length === 0 ||
      result.signatureCrc32c.trim().length === 0 ||
      !this.crc32c.verify(
        result.signature,
        result.signatureCrc32c,
      )
    ) {
      throw new Error(
        "cloud_kms_signature_integrity_failed",
      );
    }

    return Object.freeze({
      ...response,
      signatureAlgorithm:
        camoAuthorizationSignatureAlgorithm,
      signatureEncoding:
        camoAuthorizationSignatureEncoding,
      signingKeyId:
        cloudKmsSigningKeyId(keyName),
      signature:
        Buffer.from(
          result.signature,
        ).toString("base64"),
    });
  }
}