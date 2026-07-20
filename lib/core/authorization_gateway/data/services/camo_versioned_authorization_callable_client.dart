import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/services/camo_authorization_callable_primitive.dart';
import '../models/camo_signed_authorization_transport_result.dart';
import 'camo_signed_authorization_contract_transport_dispatcher.dart';

final class CamoVersionedAuthorizationCallableClient {
  const CamoVersionedAuthorizationCallableClient({
    required this.primitive,
    required this.dispatcher,
  });

  final CamoAuthorizationCallablePrimitive primitive;
  final CamoSignedAuthorizationContractTransportDispatcher dispatcher;

  Future<CamoResult<CamoSignedAuthorizationTransportResult>> authorize({
    required Map<String, Object?> payload,
    required String expectedRequestId,
  }) async {
    final String normalizedRequestId = expectedRequestId.trim();

    if (payload.isEmpty ||
        normalizedRequestId.isEmpty ||
        payload['requestId'] != normalizedRequestId) {
      return const CamoError<CamoSignedAuthorizationTransportResult>(
        CamoValidationFailure(
          code: 'versioned_authorization_callable_request_invalid',
          message: 'Versioned authorization callable request is invalid.',
        ),
      );
    }

    final Object? rawResponse;

    try {
      rawResponse = await primitive.call(
        Map<String, Object?>.unmodifiable(payload),
      );
    } on Object {
      return const CamoError<CamoSignedAuthorizationTransportResult>(
        CamoNetworkFailure(
          code: 'versioned_authorization_callable_unavailable',
          message: 'Versioned authorization callable request failed closed.',
        ),
      );
    }

    if (rawResponse is! Map) {
      return const CamoError<CamoSignedAuthorizationTransportResult>(
        CamoSecurityFailure(
          code: 'versioned_authorization_callable_response_invalid',
          message: 'Versioned authorization callable response is invalid.',
        ),
      );
    }

    try {
      final Map<Object?, Object?> responsePayload =
          Map<Object?, Object?>.unmodifiable(
            Map<Object?, Object?>.from(rawResponse),
          );

      final CamoSignedAuthorizationTransportResult transportResult =
          await dispatcher.decodeAndVerify(
            payload: responsePayload,
            expectedRequestId: normalizedRequestId,
          );

      return CamoSuccess<CamoSignedAuthorizationTransportResult>(
        transportResult,
      );
    } on Object {
      return const CamoError<CamoSignedAuthorizationTransportResult>(
        CamoSecurityFailure(
          code: 'versioned_authorization_callable_response_rejected',
          message:
              'Versioned authorization callable response failed verification.',
        ),
      );
    }
  }
}
