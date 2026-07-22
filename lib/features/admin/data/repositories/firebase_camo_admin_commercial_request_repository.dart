import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/repositories/camo_admin_commercial_request_repository.dart';

final class FirebaseCamoAdminCommercialRequestRepository
    implements CamoAdminCommercialRequestRepository {
  FirebaseCamoAdminCommercialRequestRepository({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  @override
  Future<List<CamoPendingCommercialRequest>> listPendingRequests() async {
    final HttpsCallableResult<Object?> result = await _functions
        .httpsCallable('listPendingCommercialAccessRequests')
        .call<Object?>();

    final Object? raw = result.data;
    if (raw is! Map<Object?, Object?> || raw['requests'] is! List<Object?>) {
      throw const FormatException('Invalid pending request response.');
    }

    return (raw['requests'] as List<Object?>)
        .map(_decodePendingRequest)
        .toList(growable: false);
  }

  @override
  Future<CamoApprovedCommercialRequest> approveRequest({
    required String requestId,
    required int durationDays,
  }) async {
    final HttpsCallableResult<Object?> result = await _functions
        .httpsCallable('approveCommercialAccessRequest')
        .call<Object?>({'requestId': requestId, 'durationDays': durationDays});

    final Object? raw = result.data;
    if (raw is! Map<Object?, Object?> || raw['success'] != true) {
      throw const FormatException('Invalid approval response.');
    }

    final DateTime? expiresAt = DateTime.tryParse(
      _requiredString(raw['expiresAt'], 'expiresAt'),
    );
    if (expiresAt == null) {
      throw const FormatException('Invalid approval expiry.');
    }

    final Object? rawDuration = raw['durationDays'];
    if (rawDuration is! int) {
      throw const FormatException('Invalid approval duration.');
    }

    return CamoApprovedCommercialRequest(
      requestId: _requiredString(raw['requestId'], 'requestId'),
      userId: _requiredString(raw['userId'], 'userId'),
      durationDays: rawDuration,
      expiresAt: expiresAt,
      auditEventId: _requiredString(raw['auditEventId'], 'auditEventId'),
    );
  }

  CamoPendingCommercialRequest _decodePendingRequest(Object? value) {
    if (value is! Map<Object?, Object?>) {
      throw const FormatException('Invalid pending request.');
    }

    final Object? rawRequestedAt = value['requestedAt'];
    return CamoPendingCommercialRequest(
      requestId: _requiredString(value['requestId'], 'requestId'),
      userId: _requiredString(value['userId'], 'userId'),
      userEmail: value['userEmail'] is String
          ? (value['userEmail'] as String).trim()
          : null,
      status: _requiredString(value['status'], 'status'),
      requestedAt: rawRequestedAt is String
          ? DateTime.tryParse(rawRequestedAt)
          : null,
    );
  }

  String _requiredString(Object? value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing $field.');
    }
    return value.trim();
  }
}
