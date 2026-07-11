// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../authorization/domain/entities/camo_enterprise_authorization_request.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoOperationExecutionContext {
  CamoOperationExecutionContext({
    required this.authorizationRequest,
    Map<String, String> executionAttributes = const <String, String>{},
  }) : executionAttributes = Map<String, String>.unmodifiable(
         executionAttributes,
       );
  final CamoEnterpriseAuthorizationRequest authorizationRequest;
  final Map<String, String> executionAttributes;
}
