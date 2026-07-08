// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crypto/encryption/camo_crypto_facade.dart';
import '../../../../core/di/injection_container.dart';
import 'workspace_state.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final workspaceControllerProvider =
    NotifierProvider<WorkspaceController, WorkspaceState>(
  WorkspaceController.new,
);

// ---------------------------------------------------------------------------
// Workspace Controller
// ---------------------------------------------------------------------------

class WorkspaceController extends Notifier<WorkspaceState> {
  @override
  WorkspaceState build() {
    return const WorkspaceState();
  }

  // ---------------------------------------------------------------------------
  // Encode
  // ---------------------------------------------------------------------------

  Future<void> encode({
    required String pairingId,
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final CamoCryptoFacade cryptoFacade = sl<CamoCryptoFacade>();

      final String output = await cryptoFacade.encodeForPair(
        pairingId: pairingId,
        plainText: plainText,
        subject: subject,
        camouflageEnabled: camouflageEnabled,
      );

      state = state.copyWith(
        isLoading: false,
        output: output,
        errorMessage: null,
      );
    } catch (error, stackTrace) {
      debugPrint('WORKSPACE ENCODE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Encoding failed.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Decode
  // ---------------------------------------------------------------------------

  Future<void> decode({
    required String pairingId,
    required String encodedText,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final CamoCryptoFacade cryptoFacade = sl<CamoCryptoFacade>();

      final String output = await cryptoFacade.decodeForPair(
        pairingId: pairingId,
        encodedText: encodedText,
      );

      state = state.copyWith(
        isLoading: false,
        output: output,
        errorMessage: null,
      );
    } catch (error, stackTrace) {
      debugPrint('WORKSPACE DECODE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Decoding failed.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------

  void clearOutput() {
    state = state.copyWith(
      output: '',
      errorMessage: null,
    );
  }
}