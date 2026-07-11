// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------

import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/entities/camo_authorization_transport_request.dart';
import '../../domain/entities/camo_authorization_transport_response.dart';
import '../../domain/services/camo_authorization_transport.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------

final class FailClosedCamoAuthorizationTransport
    implements CamoAuthorizationTransport {
  const FailClosedCamoAuthorizationTransport();

  @override
  Future<CamoResult<CamoAuthorizationTransportResponse>> send(
    CamoAuthorizationTransportRequest request,
  ) async {
    if (!request.isValid) {
      return const CamoError<CamoAuthorizationTransportResponse>(
        CamoValidationFailure(
          code: 'invalid_authorization_transport_request',
          message: 'Authorization transport request is invalid.',
        ),
      );
    }

    return const CamoError<CamoAuthorizationTransportResponse>(
      CamoNetworkFailure(
        code: 'production_authorization_transport_unavailable',
        message:
            'Production Authorization transport is unavailable and remains fail closed.',
      ),
    );
  }
}
