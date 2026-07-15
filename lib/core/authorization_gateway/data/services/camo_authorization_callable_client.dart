import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/services/camo_authorization_callable_primitive.dart';
import '../models/camo_signed_authorization_contract_v1.dart';
import 'camo_signed_authorization_contract_v1_transport_decoder.dart';

final class CamoAuthorizationCallableClient {
  const CamoAuthorizationCallableClient({
    required this.primitive,
    required this.decoder,
  });

  final CamoAuthorizationCallablePrimitive primitive;
  final CamoSignedAuthorizationContractV1TransportDecoder decoder;

  Future<CamoResult<CamoSignedAuthorizationContractV1>> authorize({
    required Map<String, Object?> payload,
    required String expectedRequestId,
  }) async {
    if (payload.isEmpty ||
        expectedRequestId.isEmpty ||
        payload['requestId'] != expectedRequestId) {
      return const CamoError<CamoSignedAuthorizationContractV1>(
        CamoValidationFailure(
          code: 'authorization_callable_request_invalid',
          message: 'Authorization callable request is invalid.',
        ),
      );
    }

    final Object? rawResponse;

    try {
      rawResponse = await primitive.call(
        Map<String, Object?>.unmodifiable(payload),
      );
    } on Object {
      return const CamoError<CamoSignedAuthorizationContractV1>(
        CamoNetworkFailure(
          code: 'authorization_callable_unavailable',
          message: 'Authorization callable request failed closed.',
        ),
      );
    }

    if (rawResponse is! Map) {
      return const CamoError<CamoSignedAuthorizationContractV1>(
        CamoSecurityFailure(
          code: 'authorization_callable_response_invalid',
          message: 'Authorization callable response is invalid.',
        ),
      );
    }

    try {
      final Map<Object?, Object?> responsePayload =
          Map<Object?, Object?>.unmodifiable(
            Map<Object?, Object?>.from(rawResponse),
          );

      final CamoSignedAuthorizationContractV1 contract = await decoder
          .decodeAndVerify(
            payload: responsePayload,
            expectedRequestId: expectedRequestId,
          );

      return CamoSuccess<CamoSignedAuthorizationContractV1>(contract);
    } on Object {
      return const CamoError<CamoSignedAuthorizationContractV1>(
        CamoSecurityFailure(
          code: 'authorization_callable_response_rejected',
          message: 'Authorization callable response failed verification.',
        ),
      );
    }
  }
}
