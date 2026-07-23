import {
  randomUUID,
} from "node:crypto";

import {
  CamoCloudKmsClient,
} from "./camo_cloud_kms_client";
import {
  CamoCrc32cCalculator,
} from "./camo_crc32c_calculator";
import {
  CloudKmsCamoAuthorizationResponseSignerV2,
} from "./cloud_kms_authorization_response_signer_v2";
import {
  CloudKmsCamoKeyReferenceAuthorizationService,
} from "./cloud_kms_key_reference_authorization_service";
import {
  CamoCloudKmsKeyVersionInspector,
} from "./cloud_kms_key_version_inspector";
import {
  CloudKmsCamoPublicKeyMetadataProvider,
} from "./cloud_kms_public_key_metadata_provider";
import {
  GoogleCloudCamoKmsClient,
} from "./google_cloud_kms_client";

export interface CamoCloudKmsProductionAdapters {
  readonly signer: CloudKmsCamoAuthorizationResponseSignerV2;
  readonly keyAuthorizationService:
    CloudKmsCamoKeyReferenceAuthorizationService;
  readonly publicKeyMetadataProvider:
    CloudKmsCamoPublicKeyMetadataProvider;
  readonly inspector: CamoCloudKmsKeyVersionInspector;
}

export interface CamoCloudKmsProductionAdapterOptions {
  readonly keyVersionName: string;
  readonly crc32c: CamoCrc32cCalculator;
  readonly client?: CamoCloudKmsClient;
  readonly releaseIdGenerator?: () => string;
}

export function createCamoCloudKmsProductionAdapters(
  options: CamoCloudKmsProductionAdapterOptions,
): CamoCloudKmsProductionAdapters {
  const client = options.client ?? new GoogleCloudCamoKmsClient();
  const inspector = new CamoCloudKmsKeyVersionInspector(client);

  return Object.freeze({
    signer: new CloudKmsCamoAuthorizationResponseSignerV2(
      client,
      options.keyVersionName,
      options.crc32c,
    ),
    keyAuthorizationService:
      new CloudKmsCamoKeyReferenceAuthorizationService(
        inspector,
        options.keyVersionName,
        options.releaseIdGenerator ?? randomUUID,
      ),
    publicKeyMetadataProvider:
      new CloudKmsCamoPublicKeyMetadataProvider(
        client,
        options.crc32c,
      ),
    inspector,
  });
}