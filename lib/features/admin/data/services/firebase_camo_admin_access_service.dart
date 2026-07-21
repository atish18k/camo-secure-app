import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/services/camo_admin_access_service.dart';

/// Fail-closed Admin Console visibility and navigation verifier.
///
/// Access requires all of the following:
/// - a non-empty CAMO admin UID has been explicitly configured and matches;
/// - a non-empty admin email has been explicitly configured and matches;
/// - a forced-refresh Firebase token contains `camoAdmin=true`.
///
/// Any missing fact, mismatch, refresh failure, or exception denies access.
final class FirebaseCamoAdminAccessService implements CamoAdminAccessService {
  FirebaseCamoAdminAccessService({
    FirebaseAuth? firebaseAuth,
    this.expectedAdminUid = 'VSgby7BHaRd1MFplKsBAd2QmV9Z2',
    this.expectedAdminEmail = 'atish18k@gmail.com',
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final String expectedAdminUid;
  final String expectedAdminEmail;

  @override
  Future<bool> hasFreshAdminAccess() async {
    try {
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return false;
      }

      final String actualUid = user.uid.trim();
      final String lockedUid = expectedAdminUid.trim();

      if (actualUid.isEmpty || lockedUid.isEmpty || actualUid != lockedUid) {
        return false;
      }

      final String actualEmail = user.email?.trim().toLowerCase() ?? '';
      final String lockedEmail = expectedAdminEmail.trim().toLowerCase();

      if (actualEmail.isEmpty ||
          lockedEmail.isEmpty ||
          actualEmail != lockedEmail) {
        return false;
      }

      final IdTokenResult token = await user.getIdTokenResult(true);

      return token.claims?['camoAdmin'] == true;
    } catch (_) {
      return false;
    }
  }
}
