// ---------------------------------------------------------------------------
// Workspace State
// ---------------------------------------------------------------------------

class WorkspaceState {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const WorkspaceState({
    this.isLoading = false,
    this.output = '',
    this.errorMessage,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final bool isLoading;
  final String output;
  final String? errorMessage;

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------

  WorkspaceState copyWith({
    bool? isLoading,
    String? output,
    String? errorMessage,
  }) {
    return WorkspaceState(
      isLoading: isLoading ?? this.isLoading,
      output: output ?? this.output,
      errorMessage: errorMessage,
    );
  }
}