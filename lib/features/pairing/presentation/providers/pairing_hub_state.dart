// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/pairing_entity.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PairingHubState {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PairingHubState({
    required this.isLoading,
    required this.acceptedPairings,
    required this.sentRequests,
    this.errorMessage,
  });

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  const PairingHubState.initial()
      : isLoading = true,
        acceptedPairings = const <PairingEntity>[],
        sentRequests = const <PairingEntity>[],
        errorMessage = null;

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final bool isLoading;
  final List<PairingEntity> acceptedPairings;
  final List<PairingEntity> sentRequests;
  final String? errorMessage;

  // ---------------------------------------------------------------------------
  // Computed
  // ---------------------------------------------------------------------------

  bool get hasAcceptedPairings => acceptedPairings.isNotEmpty;

  bool get hasSentRequests => sentRequests.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------

  PairingHubState copyWith({
    bool? isLoading,
    List<PairingEntity>? acceptedPairings,
    List<PairingEntity>? sentRequests,
    String? errorMessage,
  }) {
    return PairingHubState(
      isLoading: isLoading ?? this.isLoading,
      acceptedPairings: acceptedPairings ?? this.acceptedPairings,
      sentRequests: sentRequests ?? this.sentRequests,
      errorMessage: errorMessage,
    );
  }
}