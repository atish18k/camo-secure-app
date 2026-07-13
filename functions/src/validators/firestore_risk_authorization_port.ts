import {
  CamoRiskAuthorizationPort,
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

export class FirestoreCamoRiskAuthorizationPort
  implements CamoRiskAuthorizationPort {
  constructor(
    private readonly reader: CamoAuthorizationDocumentReader,
  ) {}

  async evaluateRisk(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    const document = await this.reader.readDocument(
      camoAuthorizationDocumentPaths.riskDecision(
        context.operationId,
      ),
    );

    if (document === null) {
      return denied("server_risk_decision_not_found");
    }

    const operationId = readRequiredString(
      document,
      "operationId",
    );
    const decision = readRequiredString(document, "decision");
    const permitsOperation = readOptionalBoolean(
      document,
      "permitsOperation",
    );

    if (
      operationId !== context.operationId ||
      decision !== "allow" ||
      permitsOperation !== true
    ) {
      return denied("server_risk_engine_denied");
    }

    return Object.freeze({
      allowed: true,
      reasonCode: "server_risk_decision_valid",
    });
  }
}