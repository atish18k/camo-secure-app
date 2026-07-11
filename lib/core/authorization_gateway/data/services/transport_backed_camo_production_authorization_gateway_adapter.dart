// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/entities/camo_authorization_gateway_request.dart';
import '../../domain/entities/camo_authorization_gateway_response.dart';
import '../../domain/services/camo_authorization_transport.dart';
import '../../domain/services/camo_authorization_transport_mapper.dart';
import '../../domain/services/camo_production_authorization_gateway_adapter.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------

final class TransportBackedCamoProductionAuthorizationGatewayAdapter
    implements CamoProductionAuthorizationGatewayAdapter {
  const TransportBackedCamoProductionAuthorizationGatewayAdapter({
    required this._transport,
    required this._mapper,
  });

  final CamoAuthorizationTransport _transport;
  final CamoAuthorizationTransportMapper _mapper;

  @override
  Future<CamoResult<CamoAuthorizationGatewayResponse>> authorize(
    CamoAuthorizationGatewayRequest request,
  ) async {
    if (!request.isValid) {
      return const CamoError<CamoAuthorizationGatewayResponse>(
        CamoValidationFailure(
          code: 'authorization_gateway_request_invalid',
          message: 'Authorization Gateway request is invalid.',
        ),
      );
    }

    try {
      final transportRequest = _mapper.mapRequest(request);

      if (!transportRequest.isValid) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoValidationFailure(
            code: 'authorization_transport_request_invalid',
            message: 'Authorization transport request is invalid.',
          ),
        );
      }

      final transportResult = await _transport.send(transportRequest);

      if (transportResult.isFailure) {
        return CamoError<CamoAuthorizationGatewayResponse>(
          transportResult.failureOrNull ??
              const CamoNetworkFailure(
                code: 'authorization_transport_failed',
                message: 'Authorization transport failed closed.',
              ),
        );
      }

      final transportResponse = transportResult.valueOrNull;

      if (transportResponse == null || !transportResponse.isValid) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_transport_response_invalid',
            message: 'Authorization transport response is invalid.',
          ),
        );
      }

      final gatewayResponse = _mapper.mapResponse(transportResponse);

      if (gatewayResponse.requestId != request.requestId) {
        return const CamoError<CamoAuthorizationGatewayResponse>(
          CamoSecurityFailure(
            code: 'authorization_response_request_mismatch',
            message: 'Authorization response request binding failed.',
          ),
        );
      }

      return const CamoError<CamoAuthorizationGatewayResponse>(
        CamoSecurityFailure(
          code: 'authorization_response_acceptance_not_integrated',
          message:
              'Production authorization response acceptance is not active.',
        ),
      );
    } on Object catch (error) {
      return CamoError<CamoAuthorizationGatewayResponse>(
        CamoUnexpectedFailure(
          code: 'production_authorization_adapter_unexpected_failure',
          message: 'Production Authorization Gateway adapter failed closed.',
          cause: error,
        ),
      );
    }
  }
}
