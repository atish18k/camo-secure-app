import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_response.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_authorization_gateway.dart';
import 'package:camo/core/shared/failures/camo_failure.dart';
import 'package:camo/core/shared/result/camo_result.dart';

final class FailClosedCamoAuthorizationGateway
    implements CamoAuthorizationGateway {
  const FailClosedCamoAuthorizationGateway();

  @override
  Future<CamoResult<CamoAuthorizationGatewayResponse>> authorize(
    CamoAuthorizationGatewayRequest request,
  ) async {
    return const CamoError<CamoAuthorizationGatewayResponse>(
      CamoSecurityFailure(
        code: 'production_authorization_gateway_unavailable',
        message: 'Fresh server authorization is unavailable. Operation denied.',
      ),
    );
  }
}
