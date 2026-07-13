export interface CamoCloudKmsDigest {
  readonly sha256: Uint8Array;
}

export interface CamoCloudKmsSignRequest {
  readonly name: string;
  readonly digest: CamoCloudKmsDigest;
  readonly digestCrc32c: string;
}

export interface CamoCloudKmsSignResponse {
  readonly name: string;
  readonly signature: Uint8Array;
  readonly signatureCrc32c: string;
  readonly verifiedDigestCrc32c: boolean;
}

export interface CamoCloudKmsPublicKeyResponse {
  readonly name: string;
  readonly pem: string;
  readonly algorithm: string;
  readonly pemCrc32c: string;
}

export interface CamoCloudKmsKeyVersionResponse {
  readonly name: string;
  readonly state: string;
  readonly algorithm: string;
  readonly protectionLevel: string;
}

export interface CamoCloudKmsClient {
  asymmetricSign(
    request: CamoCloudKmsSignRequest,
  ): Promise<CamoCloudKmsSignResponse>;

  getPublicKey(
    keyVersionName: string,
  ): Promise<CamoCloudKmsPublicKeyResponse>;

  getKeyVersion(
    keyVersionName: string,
  ): Promise<CamoCloudKmsKeyVersionResponse>;
}