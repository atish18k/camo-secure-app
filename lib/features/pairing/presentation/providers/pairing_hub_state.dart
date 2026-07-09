// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/pairing_entity.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum PairingHubTab {
  received,
  sent,
  paired,
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PairingHubState {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PairingHubState({
    required this.isLoading,
    required this.selectedTab,
    required this.searchQuery,
    required this.receivedRequests,
    required this.sentRequests,
    required this.pairedUsers,
    this.errorMessage,
  });

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  const PairingHubState.initial()
      : isLoading = true,
        selectedTab = PairingHubTab.received,
        searchQuery = '',
        receivedRequests = const <PairingEntity>[],
        sentRequests = const <PairingEntity>[],
        pairedUsers = const <PairingEntity>[],
        errorMessage = null;

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final bool isLoading;
  final PairingHubTab selectedTab;
  final String searchQuery;

  final List<PairingEntity> receivedRequests;
  final List<PairingEntity> sentRequests;
  final List<PairingEntity> pairedUsers;

  final String? errorMessage;

  // ---------------------------------------------------------------------------
  // Computed
  // ---------------------------------------------------------------------------

  int get receivedCount => receivedRequests.length;

  int get sentCount => sentRequests.length;

  int get pairedCount => pairedUsers.length;

  bool get hasReceivedRequests => receivedRequests.isNotEmpty;

  bool get hasSentRequests => sentRequests.isNotEmpty;

  bool get hasPairedUsers => pairedUsers.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------

  PairingHubState copyWith({
    bool? isLoading,
    PairingHubTab? selectedTab,
    String? searchQuery,
    List<PairingEntity>? receivedRequests,
    List<PairingEntity>? sentRequests,
    List<PairingEntity>? pairedUsers,
    String? errorMessage,
  }) {
    return PairingHubState(
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      pairedUsers: pairedUsers ?? this.pairedUsers,
      errorMessage: errorMessage,
    );
  }
}