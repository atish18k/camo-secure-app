export type CamoAuthorizationDocument =
  Readonly<Record<string, unknown>>;

export interface CamoAuthorizationDocumentReader {
  readDocument(
    documentPath: string,
  ): Promise<CamoAuthorizationDocument | null>;
}

export function readRequiredString(
  document: CamoAuthorizationDocument,
  fieldName: string,
): string | null {
  const value = document[fieldName];

  if (typeof value !== "string") {
    return null;
  }

  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

export function readOptionalBoolean(
  document: CamoAuthorizationDocument,
  fieldName: string,
): boolean | null {
  const value = document[fieldName];

  return typeof value === "boolean" ? value : null;
}

export function readStringArray(
  document: CamoAuthorizationDocument,
  fieldName: string,
): readonly string[] | null {
  const value = document[fieldName];

  if (!Array.isArray(value)) {
    return null;
  }

  const normalized: string[] = [];

  for (const entry of value) {
    if (typeof entry !== "string" || entry.trim().length === 0) {
      return null;
    }

    normalized.push(entry.trim());
  }

  return Object.freeze(normalized);
}