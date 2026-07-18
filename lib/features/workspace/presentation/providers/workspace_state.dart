enum CamoWorkspaceOperationStatus {
  ready,
  authorizing,
  processing,
  success,
  failure,
  expired,
  blocked,
}

class WorkspaceState {
  const WorkspaceState({
    this.isLoading = false,
    this.output = '',
    this.errorMessage,
    this.operationStatus = CamoWorkspaceOperationStatus.ready,
  });

  final bool isLoading;
  final String output;
  final String? errorMessage;
  final CamoWorkspaceOperationStatus operationStatus;

  WorkspaceState copyWith({
    bool? isLoading,
    String? output,
    String? errorMessage,
    CamoWorkspaceOperationStatus? operationStatus,
  }) {
    return WorkspaceState(
      isLoading: isLoading ?? this.isLoading,
      output: output ?? this.output,
      errorMessage: errorMessage,
      operationStatus: operationStatus ?? this.operationStatus,
    );
  }
}
