import '../models/camo_signed_authorization_contract_v1.dart';
import '../models/camo_signed_authorization_contract_v2.dart';
import '../models/camo_signed_authorization_transport_result.dart';
import 'camo_signed_authorization_contract_v1_transport_decoder.dart';
import 'camo_signed_authorization_contract_v2_transport_decoder.dart';

final class CamoSignedAuthorizationContractTransportDispatcher {
  const CamoSignedAuthorizationContractTransportDispatcher({
    required this.v1Decoder,
    required this.v2Decoder,
  });

  final CamoSignedAuthorizationContractV1TransportDecoder v1Decoder;
  final CamoSignedAuthorizationContractV2TransportDecoder v2Decoder;

  Future<CamoSignedAuthorizationTransportResult> decodeAndVerify({
    required Map<Object?, Object?> payload,
    required String expectedRequestId,
  }) async {
    try {
      final Object? rawSchemaVersion = payload['schemaVersion'];
      final Object? rawCanonicalizationVersion =
          payload['canonicalizationVersion'];

      if (rawSchemaVersion == camoAuthorizationSchemaVersionV1 &&
          rawCanonicalizationVersion ==
              camoAuthorizationCanonicalizationVersionV1) {
        final CamoSignedAuthorizationContractV1 contract = await v1Decoder
            .decodeAndVerify(
              payload: payload,
              expectedRequestId: expectedRequestId,
            );

        return CamoSignedAuthorizationTransportResultV1(contract);
      }

      if (rawSchemaVersion == camoAuthorizationSchemaVersionV2 &&
          rawCanonicalizationVersion ==
              camoAuthorizationCanonicalizationVersionV2) {
        final CamoSignedAuthorizationContractV2 contract = await v2Decoder
            .decodeAndVerify(
              payload: payload,
              expectedRequestId: expectedRequestId,
            );

        return CamoSignedAuthorizationTransportResultV2(contract);
      }

      throw StateError('Unsupported signed authorization transport version.');
    } on Object {
      throw StateError(
        'Signed authorization transport dispatch failed closed.',
      );
    }
  }
}
