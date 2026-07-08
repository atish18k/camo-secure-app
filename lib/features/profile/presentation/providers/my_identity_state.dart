// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class MyIdentityState {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const MyIdentityState({
    required this.isLoading,
    required this.isVisible,
    required this.isCopied,
    required this.displayName,
    required this.camoId,
  });

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  const MyIdentityState.initial()
      : isLoading = true,
        isVisible = false,
        isCopied = false,
        displayName = '',
        camoId = '';

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final bool isLoading;
  final bool isVisible;
  final bool isCopied;

  final String displayName;
  final String camoId;

  // ---------------------------------------------------------------------------
  // Computed
  // ---------------------------------------------------------------------------

  bool get hasIdentity =>
      displayName.trim().isNotEmpty && camoId.trim().isNotEmpty;

  String get maskedCamoId {
    if (camoId.trim().isEmpty) {
      return 'CAMO-••••-••••';
    }

    if (isVisible) {
      return camoId;
    }

    final List<String> parts = camoId.split('-');

    if (parts.length >= 3) {
      return '${parts.first}-••••-••••';
    }

    return '••••••••';
  }

  // ---------------------------------------------------------------------------
  // CopyWith
  // ---------------------------------------------------------------------------

  MyIdentityState copyWith({
    bool? isLoading,
    bool? isVisible,
    bool? isCopied,
    String? displayName,
    String? camoId,
  }) {
    return MyIdentityState(
      isLoading: isLoading ?? this.isLoading,
      isVisible: isVisible ?? this.isVisible,
      isCopied: isCopied ?? this.isCopied,
      displayName: displayName ?? this.displayName,
      camoId: camoId ?? this.camoId,
    );
  }
}