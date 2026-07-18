import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/services/camo_authorized_workspace_service.dart';
import 'workspace_state.dart';

final workspaceControllerProvider =
    NotifierProvider<WorkspaceController, WorkspaceState>(
      WorkspaceController.new,
    );

class WorkspaceController extends Notifier<WorkspaceState> {
  @override
  WorkspaceState build() => const WorkspaceState();

  Future<void> encode({
    required String pairingId,
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      operationStatus: CamoWorkspaceOperationStatus.authorizing,
    );
    try {
      final String output = await sl<CamoAuthorizedWorkspaceService>().encode(
        pairingId: pairingId,
        plainText: plainText,
        subject: subject,
        camouflageEnabled: camouflageEnabled,
      );
      state = state.copyWith(
        isLoading: false,
        output: output,
        errorMessage: null,
        operationStatus: CamoWorkspaceOperationStatus.success,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Encoding failed.',
        operationStatus: CamoWorkspaceOperationStatus.failure,
      );
    }
  }

  Future<void> decode({
    required String pairingId,
    required String encodedText,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      operationStatus: CamoWorkspaceOperationStatus.authorizing,
    );
    try {
      final String output = await sl<CamoAuthorizedWorkspaceService>().decode(
        pairingId: pairingId,
        encodedText: encodedText,
      );
      state = state.copyWith(
        isLoading: false,
        output: output,
        errorMessage: null,
        operationStatus: CamoWorkspaceOperationStatus.success,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Decoding failed.',
        operationStatus: CamoWorkspaceOperationStatus.failure,
      );
    }
  }

  void clearOutput() {
    state = state.copyWith(
      output: '',
      errorMessage: null,
      operationStatus: CamoWorkspaceOperationStatus.ready,
    );
  }
}
