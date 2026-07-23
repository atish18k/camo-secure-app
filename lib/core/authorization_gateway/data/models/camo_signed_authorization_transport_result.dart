import 'camo_signed_authorization_contract_v2.dart';

sealed class CamoSignedAuthorizationTransportResult {
  const CamoSignedAuthorizationTransportResult();

  int get schemaVersion;
}

final class CamoSignedAuthorizationTransportResultV2
    extends CamoSignedAuthorizationTransportResult {
  const CamoSignedAuthorizationTransportResultV2(this.contract);

  final CamoSignedAuthorizationContractV2 contract;

  @override
  int get schemaVersion => contract.schemaVersion;
}
