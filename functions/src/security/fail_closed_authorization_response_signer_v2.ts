import {
  CamoAuthorizationResponseSignerV2,
} from "../domain/authorization_ports_v2";
import {
  CamoSignedAuthorizationResponseV2,
  CamoUnsignedAuthorizationResponseV2,
} from "../domain/authorization_types_v2";

export class FailClosedCamoAuthorizationResponseSignerV2
implements CamoAuthorizationResponseSignerV2 {
  async sign(
    response: CamoUnsignedAuthorizationResponseV2,
  ): Promise<CamoSignedAuthorizationResponseV2> {
    void response;

    throw new Error(
      "production_authorization_response_signer_v2_unavailable",
    );
  }
}