import {
  CamoUserAuthorizationPort,
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
} from "../infrastructure/authorization_document_reader";

function denied(reasonCode: string): CamoDomainDecision {
  return Object.freeze({allowed: false, reasonCode});
}

export class FirestoreCamoUserAuthorizationPort
  implements CamoUserAuthorizationPort {
  constructor(
    private readonly reader: CamoAuthorizationDocumentReader,
  ) {}

  async validateUser(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    const document = await this.reader.readDocument(
      camoAuthorizationDocumentPaths.user(context.userId),
    );

    if (document === null) {
      return denied("server_user_not_found");
    }

    const uid = readRequiredString(document, "uid");
    const disabled = readOptionalBoolean(document, "disabled");
    const status = readRequiredString(document, "status");

    if (uid !== context.userId) {
      return denied("server_user_identity_mismatch");
    }

    if (disabled !== false) {
      return denied("server_user_disabled_or_unverified");
    }

    if (status !== "active") {
      return denied("server_user_not_active");
    }

    return Object.freeze({
      allowed: true,
      reasonCode: "server_user_valid",
    });
  }
}