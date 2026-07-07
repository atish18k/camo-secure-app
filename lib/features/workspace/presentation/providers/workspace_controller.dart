// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------


import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crypto/encryption/camo_message_crypto_service.dart';
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
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static final Uint8List _devKey = Uint8List.fromList(
    List<int>.filled(32, 7),
  );

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  WorkspaceState build() {
    return const WorkspaceState();
  }

  // ---------------------------------------------------------------------------
  // Encode
  // ---------------------------------------------------------------------------

  Future<void> encode({
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final CamoMessageCryptoService cryptoService =
          sl<CamoMessageCryptoService>();

      final String output = await cryptoService.encode(
        plainText: plainText,
        key: _devKey,
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
    required String encodedText,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final CamoMessageCryptoService cryptoService =
          sl<CamoMessageCryptoService>();

      final String output = await cryptoService.decode(
        encodedText: encodedText,
        key: _devKey,
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