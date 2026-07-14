// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/camo_authorized_workspace_service.dart';
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final CamoAuthorizedWorkspaceService workspaceService =
          sl<CamoAuthorizedWorkspaceService>();

      final String output = await workspaceService.encode(
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
    } catch (_) {
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final CamoAuthorizedWorkspaceService workspaceService =
          sl<CamoAuthorizedWorkspaceService>();

      final String output = await workspaceService.decode(
        pairingId: pairingId,
        encodedText: encodedText,
      );

      state = state.copyWith(
        isLoading: false,
        output: output,
        errorMessage: null,
      );
    } catch (_) {
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
    state = state.copyWith(output: '', errorMessage: null);
  }
}
