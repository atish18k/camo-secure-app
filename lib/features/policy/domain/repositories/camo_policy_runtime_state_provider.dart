// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/camo_policy_operation.dart';
import '../entities/camo_policy_runtime_state.dart';

// ---------------------------------------------------------------------------
// CAMO Policy Runtime State Provider
// ---------------------------------------------------------------------------

/// Provides verified runtime policy state before a protected operation.
///
/// Implementations must obtain values from trusted sources such as:
///
/// - authenticated identity state
/// - device-binding services
/// - license services
/// - server-side message policy records
/// - pairing and block-status repositories
///
/// Plaintext, encryption keys, private keys, and decrypted content must never
/// be supplied to or returned from this provider.
abstract class CamoPolicyRuntimeStateProvider {
  Future<CamoPolicyRuntimeState> getRuntimeState({
    required CamoPolicyOperation operation,
    required String pairingId,
    String? messageId,
  });
}