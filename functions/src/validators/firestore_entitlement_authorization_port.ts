import {
  CamoEntitlementAuthorizationPort,
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

export class FirestoreCamoEntitlementAuthorizationPort
  implements CamoEntitlementAuthorizationPort {
  constructor(
    private readonly reader: CamoAuthorizationDocumentReader,
    private readonly clock: () => Date = () => new Date(),
  ) {}

  async validateEntitlements(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoDomainDecision> {
    const document = await this.reader.readDocument(
      camoAuthorizationDocumentPaths.commercialAccess(
        context.userId,
      ),
    );

    if (document === null) {
      return denied("server_commercial_access_not_found");
    }

    const userId = readRequiredString(document, "userId");
    const subscriptionActive = readOptionalBoolean(
      document,
      "subscriptionActive",
    );
    const grantedEntitlements = readStringArray(
      document,
      "grantedEntitlements",
    );
    const expiresAt = readRequiredString(document, "expiresAt");

    if (
      userId !== context.userId ||
      subscriptionActive !== true ||
      grantedEntitlements === null ||
      expiresAt === null
    ) {
      return denied("server_commercial_access_invalid");
    }

    const expiryMilliseconds = Date.parse(expiresAt);

    if (
      !Number.isFinite(expiryMilliseconds) ||
      this.clock().getTime() >= expiryMilliseconds
    ) {
      return denied("server_commercial_access_expired");
    }

    for (const requiredEntitlement of
      context.requiredEntitlements) {
      if (!grantedEntitlements.includes(requiredEntitlement)) {
        return denied("server_required_entitlement_missing");
      }
    }

    return Object.freeze({
      allowed: true,
      reasonCode: "server_commercial_access_valid",
    });
  }
}