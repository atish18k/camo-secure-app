import {
  CamoSignedAuthorizationResponseV2,
  CamoUnsignedAuthorizationResponseV2,
} from "./authorization_types_v2";

export interface CamoAuthorizationResponseSignerV2 {
  sign(
    response: CamoUnsignedAuthorizationResponseV2,
  ): Promise<CamoSignedAuthorizationResponseV2>;
}