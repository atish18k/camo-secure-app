import {
  CamoPairAuthorizationPort,
} from "../domain/authorization_ports";
import {
  CamoDomainDecision,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  camoAuthorizationDocumentPaths,
} from "../infrastructure/authorization_document_paths";
import {
  CamoAuthorizationDocumentReader,
  readOptionalBoolean,
  readRequiredString,
  readStringArray,
} from "../infrastructure/authorization_document_reader";

function denied(reasonCode: string): CamoDomainDecision {
  return Object.freeze({allowed: false, reasonCode});
}

export class FirestoreCamoPairAuthorizationPort
  implements CamoPairAuthorizationPort {
  constructor(
    private readonly reader: CamoAuthorizationDocumentReader,
  ) {}

  async validatePair(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    const pairId = context.pairId?.trim() ?? "";

    if (pairId.length === 0) {
      return denied("server_pair_context_required");
    }

    const document = await this.reader.readDocument(
      camoAuthorizationDocumentPaths.pairing(pairId),
    );

    if (document === null) {
      return denied("server_pair_not_found");
    }

    const storedPairId = readRequiredString(document, "pairId");
    const status = readRequiredString(document, "status");
    const active = readOptionalBoolean(document, "active");
    const participantUserIds = readStringArray(
      document,
      "participantUserIds",
    );

    if (storedPairId !== pairId) {
      return denied("server_pair_identifier_mismatch");
    }

    if (
      status !== "active" ||
      active !== true ||
      participantUserIds === null ||
      !participantUserIds.includes(context.userId)
    ) {
      return denied("server_pair_not_authorized");
    }

    return Object.freeze({
      allowed: true,
      reasonCode: "server_pair_valid",
    });
  }
}