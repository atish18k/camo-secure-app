import {
  Firestore,
} from "firebase-admin/firestore";

import {
  CamoAuthorizationDocument,
  CamoAuthorizationDocumentReader,
} from "./authorization_document_reader";

export class FirebaseAdminCamoAuthorizationDocumentReader
  implements CamoAuthorizationDocumentReader {
  constructor(
    private readonly firestore: Firestore,
  ) {}

  async readDocument(
    documentPath: string,
  ): Promise<CamoAuthorizationDocument | null> {
    const normalizedPath = documentPath.trim();

    if (
      normalizedPath.length === 0 ||
      normalizedPath.startsWith("/") ||
      normalizedPath.endsWith("/") ||
      normalizedPath.split("/").length % 2 !== 0
    ) {
      return null;
    }

    try {
      const snapshot = await this.firestore.doc(normalizedPath).get();

      if (!snapshot.exists) {
        return null;
      }

      const value = snapshot.data();

      if (value === undefined || value === null) {
        return null;
      }

      return Object.freeze({...value});
    } catch {
      return null;
    }
  }
}