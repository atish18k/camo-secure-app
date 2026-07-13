import '../../../operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import '../../domain/entities/camo_enterprise_authorization_request.dart';
import '../../domain/services/camo_enterprise_authorization_operation_request_mapper.dart';

final class DefaultCamoEnterpriseAuthorizationOperationRequestMapper
    implements CamoEnterpriseAuthorizationOperationRequestMapper {
  const DefaultCamoEnterpriseAuthorizationOperationRequestMapper({
    required this.requestIdGenerator,
    required this.clock,
  });

  final String Function() requestIdGenerator;
  final DateTime Function() clock;

  @override
  CamoEnterpriseOperationRequest map(
    CamoEnterpriseAuthorizationRequest request,
  ) {
    if (!request.isValid) {
      throw StateError('Enterprise authorization request is invalid.');
    }

    final String requestId = requestIdGenerator().trim();

    if (requestId.isEmpty) {
      throw StateError('Enterprise operation request identifier is invalid.');
    }

    final DateTime createdAt = clock().toUtc();

    return CamoEnterpriseOperationRequest(
      requestId: requestId,
      authorizationRequest: request,
      createdAt: createdAt,
      payloadReference: request.operationId.trim(),
      metadata: const <String, String>{
        'source': 'enterpriseAuthorizationService',
        'authorizationMode': 'freshServerAuthorization',
      },
    );
  }
}
