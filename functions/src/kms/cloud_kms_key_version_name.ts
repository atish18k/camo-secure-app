const keyVersionPattern =
  /^projects\/[a-z][a-z0-9-]{4,28}[a-z0-9]\/locations\/[a-z0-9-]+\/keyRings\/[A-Za-z0-9_-]+\/cryptoKeys\/[A-Za-z0-9_-]+\/cryptoKeyVersions\/[1-9][0-9]*$/;

export function normalizeCloudKmsKeyVersionName(
  value: string,
): string {
  const normalized = value.trim();

  if (!keyVersionPattern.test(normalized)) {
    throw new Error(
      "cloud_kms_key_version_name_invalid",
    );
  }

  return normalized;
}

export function cloudKmsSigningKeyId(
  keyVersionName: string,
): string {
  const normalized =
    normalizeCloudKmsKeyVersionName(
      keyVersionName,
    );

  const segments = normalized.split("/");

  return [
    segments[1],
    segments[3],
    segments[5],
    segments[7],
    segments[9],
  ].join(":");
}