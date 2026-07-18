import {CamoRiskAuthorizationPort} from "../domain/authorization_ports";
import {CamoDomainDecision, CamoServerAuthorizationContext} from "../domain/authorization_types";
import {camoAuthorizationDocumentPaths} from "../infrastructure/authorization_document_paths";
import {CamoAuthorizationDocumentReader, readOptionalBoolean, readRequiredString} from "../infrastructure/authorization_document_reader";

function denied(reasonCode: string): CamoDomainDecision {
  return Object.freeze({allowed: false, reasonCode});
}

function validDate(value: string | null): Date | null {
  if (value === null) return null;
  const date = new Date(value);
  return Number.isFinite(date.getTime()) ? date : null;
}

export class FirestoreCamoRiskAuthorizationPort implements CamoRiskAuthorizationPort {
  constructor(
    private readonly reader: CamoAuthorizationDocumentReader,
    private readonly clock?: () => Date,
  ) {}

  async evaluateRisk(context: CamoServerAuthorizationContext): Promise<CamoDomainDecision> {
    const document = await this.reader.readDocument(
      camoAuthorizationDocumentPaths.riskDecision(context.operationId),
    );
    if (document === null) return denied("server_risk_decision_not_found");

    const now = this.clock?.() ?? new Date(context.serverReceivedAt);
    const createdAt = validDate(readRequiredString(document, "createdAt"));
    const expiresAt = validDate(readRequiredString(document, "expiresAt"));
    const pairId = context.pairId?.trim();
    const messageId = context.messageId?.trim();
    const bindingsValid =
      document.schemaVersion === 1 &&
      readRequiredString(document, "operationId") === context.operationId &&
      readRequiredString(document, "userId") === context.userId &&
      readRequiredString(document, "deviceId") === context.deviceId &&
      readRequiredString(document, "decision") === "allow" &&
      readOptionalBoolean(document, "permitsOperation") === true &&
      (pairId === undefined || readRequiredString(document, "pairId") === pairId) &&
      (messageId === undefined || readRequiredString(document, "messageId") === messageId) &&
      createdAt !== null && expiresAt !== null &&
      Number.isFinite(now.getTime()) && createdAt.getTime() <= now.getTime() &&
      now.getTime() < expiresAt.getTime();

    return bindingsValid ? Object.freeze({allowed: true, reasonCode: "server_risk_decision_valid"}) :
      denied("server_risk_engine_denied");
  }
}
