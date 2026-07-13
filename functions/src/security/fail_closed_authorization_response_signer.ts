import {
  CamoSignedAuthorizationResponse,
  CamoUnsignedAuthorizationResponse,
} from "../domain/authorization_types";
import {
  CamoAuthorizationResponseSigner,
} from "../domain/authorization_ports";

export class FailClosedCamoAuthorizationResponseSigner
  implements CamoAuthorizationResponseSigner {
  async sign(
    response: CamoUnsignedAuthorizationResponse,
  ): Promise<CamoSignedAuthorizationResponse> {
    void response;

    throw new Error(
      "production_authorization_response_signer_unavailable",
    );
  }
}