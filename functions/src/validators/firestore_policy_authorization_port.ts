import {
  CamoPolicyAuthorizationPort,
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
  readStringArray,
} from "../infrastructure/authorization_document_reader";

function denied(reasonCode: string): CamoDomainDecision {
  return Object.freeze({allowed: false, reasonCode});
}

export class FirestoreCamoPolicyAuthorizationPort
  implements CamoPolicyAuthorizationPort {
  constructor(
    private readonly reader: CamoAuthorizationDocumentReader,
  ) {}

  async evaluatePolicy(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    const document = await this.reader.readDocument(
      camoAuthorizationDocumentPaths.globalPolicy(),
    );

    if (document === null) {
      return denied("server_policy_not_found");
    }

    const enabled = readOptionalBoolean(document, "enabled");
    const onlineAuthorizationRequired = readOptionalBoolean(
      document,
      "onlineAuthorizationRequired",
    );
    const offlineOperationsAllowed = readOptionalBoolean(
      document,
      "offlineOperationsAllowed",
    );
    const allowedOperations = readStringArray(
      document,
      "allowedOperations",
    );

    if (
      enabled !== true ||
      onlineAuthorizationRequired !== true ||
      offlineOperationsAllowed !== false ||
      allowedOperations === null ||
      !allowedOperations.includes(context.operationType)
    ) {
      return denied("server_enterprise_policy_denied");
    }

    return Object.freeze({
      allowed: true,
      reasonCode: "server_enterprise_policy_valid",
    });
  }
}