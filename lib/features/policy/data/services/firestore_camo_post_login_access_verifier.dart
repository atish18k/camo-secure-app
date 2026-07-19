import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/camo_device_identity_service.dart';
import '../../domain/services/camo_post_login_access_verifier.dart';

/// Verifies post-login commercial access using fresh server facts.
///
/// This verifier never grants a subscription or entitlement locally. It reads
/// the canonical server-owned commercialAccessV2/current document and permits
/// navigation only when every required fact is explicitly valid.
///
/// Device approval and local public-key binding remain enforced independently
/// by [CamoDeviceApprovalGate].
final class FirestoreCamoPostLoginAccessVerifier
    implements CamoPostLoginAccessVerifier {
  FirestoreCamoPostLoginAccessVerifier({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
    required CamoDeviceIdentityService deviceIdentityService,
    DateTime Function()? clock,
  }) : this._(
         firestore: firestore,
         authRepository: authRepository,
         deviceIdentityService: deviceIdentityService,
         clock: clock ?? DateTime.now,
       );

  const FirestoreCamoPostLoginAccessVerifier._({
    required this._firestore,
    required this._authRepository,
    required this._deviceIdentityService,
    required this._clock,
  });

  static const String _requiredPlanId = 'camo_monthly_inr_199';
  static const int _requiredMonthlyPriceInr = 199;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final CamoDeviceIdentityService _deviceIdentityService;
  final DateTime Function() _clock;

  @override
  Future<CamoPostLoginAccessDecision> verify() async {
    final String userId = _authRepository.currentUserId?.trim() ?? '';

    if (userId.isEmpty) {
      return const CamoPostLoginAccessDecision.deny(
        'authenticated_user_missing',
      );
    }

    final String deviceId;

    try {
      deviceId = (await _deviceIdentityService.getDeviceId()).trim();
    } on Object {
      return const CamoPostLoginAccessDecision.deny(
        'local_device_identity_unavailable',
      );
    }

    if (deviceId.isEmpty) {
      return const CamoPostLoginAccessDecision.deny(
        'local_device_identity_missing',
      );
    }

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('commercialAccessV2')
          .doc('current')
          .get(const GetOptions(source: Source.server));

      if (!snapshot.exists) {
        return const CamoPostLoginAccessDecision.deny(
          'server_commercial_access_v2_not_found',
        );
      }

      final Map<String, dynamic>? data = snapshot.data();

      if (data == null) {
        return const CamoPostLoginAccessDecision.deny(
          'server_commercial_access_v2_empty',
        );
      }

      return _evaluate(
        data: data,
        expectedUserId: userId,
        expectedDeviceId: deviceId,
      );
    } on FirebaseException {
      return const CamoPostLoginAccessDecision.deny(
        'server_commercial_access_verification_failed',
      );
    } on Object {
      return const CamoPostLoginAccessDecision.deny(
        'server_commercial_access_verification_failed',
      );
    }
  }

  CamoPostLoginAccessDecision _evaluate({
    required Map<String, dynamic> data,
    required String expectedUserId,
    required String expectedDeviceId,
  }) {
    final Object? schemaVersion = data['schemaVersion'];
    final String userId = _string(data['userId']);
    final String planId = _string(data['planId']);
    final Object? monthlyPriceInr = data['monthlyPriceInr'];
    final String licenseStatus = _string(data['licenseStatus']);
    final String subscriptionStatus = _string(data['subscriptionStatus']);
    final String billingState = _string(data['billingState']);
    final Object? deviceAllowance = data['deviceAllowance'];
    final List<String>? grantedEntitlements = _stringList(
      data['grantedEntitlements'],
    );
    final DateTime? expiresAt = _dateTime(data['expiresAt']);

    if (schemaVersion != 2 ||
        userId != expectedUserId ||
        planId != _requiredPlanId ||
        monthlyPriceInr != _requiredMonthlyPriceInr ||
        licenseStatus != 'active' ||
        subscriptionStatus != 'active' ||
        billingState != 'paid' ||
        deviceAllowance is! int ||
        deviceAllowance < 1 ||
        grantedEntitlements == null ||
        expiresAt == null ||
        !_clock().toUtc().isBefore(expiresAt)) {
      return const CamoPostLoginAccessDecision.deny(
        'server_commercial_access_v2_invalid',
      );
    }

    if (!grantedEntitlements.contains('baseEncoding') &&
        !grantedEntitlements.contains('base_encoding')) {
      return const CamoPostLoginAccessDecision.deny(
        'server_base_encoding_entitlement_missing',
      );
    }

    if (!grantedEntitlements.contains('baseDecoding') &&
        !grantedEntitlements.contains('base_decoding')) {
      return const CamoPostLoginAccessDecision.deny(
        'server_base_decoding_entitlement_missing',
      );
    }

    final List<String>? permittedDeviceIds = _stringList(
      data['permittedDeviceIds'],
    );

    if (permittedDeviceIds != null &&
        !permittedDeviceIds.contains(expectedDeviceId)) {
      return const CamoPostLoginAccessDecision.deny(
        'server_device_commercial_binding_missing',
      );
    }

    return const CamoPostLoginAccessDecision.allow();
  }

  static String _string(Object? value) {
    return value is String ? value.trim() : '';
  }

  static List<String>? _stringList(Object? value) {
    if (value is! List<Object?>) {
      return null;
    }

    final List<String> result = <String>[];

    for (final Object? item in value) {
      if (item is! String || item.trim().isEmpty) {
        return null;
      }
      result.add(item.trim());
    }

    return List<String>.unmodifiable(result);
  }

  static DateTime? _dateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }

    if (value is String) {
      return DateTime.tryParse(value)?.toUtc();
    }

    return null;
  }
}
