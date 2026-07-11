import '../../domain/services/camo_authorized_workspace_service.dart';

final class FailClosedCamoAuthorizedWorkspaceService
    implements CamoAuthorizedWorkspaceService {
  const FailClosedCamoAuthorizedWorkspaceService();

  static const String authorizationUnavailableMessage =
      'Fresh server authorization is unavailable. '
      'The operation was blocked.';

  Never _deny() {
    throw StateError(authorizationUnavailableMessage);
  }

  @override
  Future<String> encode({
    required String pairingId,
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    return _deny();
  }

  @override
  Future<String> decode({
    required String pairingId,
    required String encodedText,
  }) async {
    return _deny();
  }
}
