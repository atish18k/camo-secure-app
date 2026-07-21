import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/services/camo_authorization_callable_primitive.dart';
import '../models/camo_signed_authorization_contract_v2.dart';
import 'camo_signed_authorization_contract_v2_transport_decoder.dart';

final class CamoV2AuthorizationCallableClient {
  const CamoV2AuthorizationCallableClient({
    required this.primitive,
    required this.decoder,
  });

  final CamoAuthorizationCallablePrimitive primitive;
  final CamoSignedAuthorizationContractV2TransportDecoder decoder;

  Future<CamoResult<CamoSignedAuthorizationContractV2>> authorize({
    required Map<String, Object?> payload,
    required String expectedRequestId,
  }) async {
    final String normalizedRequestId = expectedRequestId.trim();

    if (payload.isEmpty ||
        normalizedRequestId.isEmpty ||
        payload['requestId'] != normalizedRequestId) {
      return const CamoError<CamoSignedAuthorizationContractV2>(
        CamoValidationFailure(
          code: 'v2_authorization_callable_request_invalid',
          message: 'V2 authorization callable request is invalid.',
        ),
      );
    }

    final Object? rawResponse;

    try {
      rawResponse = await primitive.call(
        Map<String, Object?>.unmodifiable(payload),
      );
    } on Object {
      return const CamoError<CamoSignedAuthorizationContractV2>(
        CamoNetworkFailure(
          code: 'v2_authorization_callable_unavailable',
          message: 'V2 authorization callable request failed closed.',
        ),
      );
    }

    if (rawResponse is! Map) {
      return const CamoError<CamoSignedAuthorizationContractV2>(
        CamoSecurityFailure(
          code: 'v2_authorization_callable_response_invalid',
          message: 'V2 authorization callable response is invalid.',
        ),
      );
    }

    try {
      final Map<Object?, Object?> responsePayload =
          Map<Object?, Object?>.unmodifiable(
            Map<Object?, Object?>.from(rawResponse),
          );

      final CamoSignedAuthorizationContractV2 contract = await decoder
          .decodeAndVerify(
            payload: responsePayload,
            expectedRequestId: normalizedRequestId,
          );

      return CamoSuccess<CamoSignedAuthorizationContractV2>(contract);
    } on Object {
      return const CamoError<CamoSignedAuthorizationContractV2>(
        CamoSecurityFailure(
          code: 'v2_authorization_callable_response_rejected',
          message: 'V2 authorization callable response failed verification.',
        ),
      );
    }
  }
}
