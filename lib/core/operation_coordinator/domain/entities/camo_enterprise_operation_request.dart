// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../authorization/domain/entities/camo_enterprise_authorization_request.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoEnterpriseOperationRequest {
  CamoEnterpriseOperationRequest({
    required this.requestId,
    required this.authorizationRequest,
    required this.createdAt,
    this.payloadReference,
    Map<String, String> metadata = const <String, String>{},
  }) : metadata = Map<String, String>.unmodifiable(metadata);
  final String requestId;
  final CamoEnterpriseAuthorizationRequest authorizationRequest;
  final DateTime createdAt;
  final String? payloadReference;
  final Map<String, String> metadata;
  bool get isValid {
    return requestId.isNotEmpty && authorizationRequest.isValid;
  }
}
