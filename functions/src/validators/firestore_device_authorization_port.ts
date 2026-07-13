import {
  CamoDeviceAuthorizationPort,
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

export class FirestoreCamoDeviceAuthorizationPort
  implements CamoDeviceAuthorizationPort {
  constructor(
    private readonly reader: CamoAuthorizationDocumentReader,
  ) {}

  async validateDevice(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    const document = await this.reader.readDocument(
      camoAuthorizationDocumentPaths.device(
        context.userId,
        context.deviceId,
      ),
    );

    if (document === null) {
      return denied("server_trusted_device_not_found");
    }

    const deviceId = readRequiredString(document, "deviceId");
    const userId = readRequiredString(document, "userId");
    const status = readRequiredString(document, "status");
    const approved = readOptionalBoolean(document, "approved");
    const revoked = readOptionalBoolean(document, "revoked");
    const publicKey = readRequiredString(document, "publicKey");

    if (
      deviceId !== context.deviceId ||
      userId !== context.userId
    ) {
      return denied("server_trusted_device_binding_mismatch");
    }

    if (
      status !== "active" ||
      approved !== true ||
      revoked !== false ||
      publicKey === null
    ) {
      return denied("server_trusted_device_not_approved");
    }

    return Object.freeze({
      allowed: true,
      reasonCode: "server_trusted_device_valid",
    });
  }
}