import {
  createHash,
} from "node:crypto";

import {
  CamoAuthorizationResponseSignerV2,
} from "../domain/authorization_ports_v2";
import {
  CamoSignedAuthorizationResponseV2,
  CamoUnsignedAuthorizationResponseV2,
} from "../domain/authorization_types_v2";
import {
  canonicalizeAuthorizationResponseV2,
} from "../security/authorization_canonicalizer_v2";
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

export class CloudKmsCamoAuthorizationResponseSignerV2
implements CamoAuthorizationResponseSignerV2 {
  constructor(
    private readonly client: CamoCloudKmsClient,
    private readonly keyVersionName: string,
    private readonly crc32c: CamoCrc32cCalculator,
  ) {}

  async sign(
    response: CamoUnsignedAuthorizationResponseV2,
  ): Promise<CamoSignedAuthorizationResponseV2> {
    if (response.authorized !== true) {
      throw new Error(
        "cloud_kms_v2_refused_unsigned_denial",
      );
    }

    const keyName =
      normalizeCloudKmsKeyVersionName(
        this.keyVersionName,
      );

    const canonical =
      canonicalizeAuthorizationResponseV2(
        response,
      );

    const digest = createHash("sha256")
      .update(canonical)
      .digest();

    const digestBytes = Uint8Array.from(digest);

    const result =
      await this.client.asymmetricSign({
        name: keyName,
        digest: {
          sha256: digestBytes,
        },
        digestCrc32c:
          this.crc32c.calculate(digestBytes),
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
        "cloud_kms_v2_signature_integrity_failed",
      );
    }

    return Object.freeze({
      ...response,
      signatureAlgorithm:
        "EC_SIGN_P256_SHA256",
      signatureEncoding:
        "DER_BASE64",
      signingKeyId:
        cloudKmsSigningKeyId(keyName),
      signature:
        Buffer.from(
          result.signature,
        ).toString("base64"),
    });
  }
}