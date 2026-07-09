// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../domain/entities/pairing_entity.dart';
import '../../domain/repositories/pairing_repository.dart';
import 'pairing_hub_state.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final pairingHubControllerProvider =
    NotifierProvider<PairingHubController, PairingHubState>(
  PairingHubController.new,
);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class PairingHubController extends Notifier<PairingHubState> {
  StreamSubscription<List<PairingEntity>>? _receivedSubscription;
  StreamSubscription<List<PairingEntity>>? _sentSubscription;
  StreamSubscription<List<PairingEntity>>? _pairedSubscription;

  @override
  PairingHubState build() {
    ref.onDispose(_disposeSubscriptions);
    Future<void>.microtask(_load);
    return const PairingHubState.initial();
  }

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> _load() async {
    final String? currentUserId = sl<GetCurrentUserIdUseCase>()();

    if (currentUserId == null || currentUserId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please login again to view pairings.',
      );
      return;
    }

    final PairingRepository repository = sl<PairingRepository>();

    _receivedSubscription = repository
        .watchPendingRequests(currentUserId)
        .listen(_onReceivedRequestsChanged);

    _sentSubscription = repository
        .watchSentRequests(currentUserId)
        .listen(_onSentRequestsChanged);

    _pairedSubscription = repository
        .watchAcceptedPairings(currentUserId)
        .listen(_onPairedUsersChanged);
  }

  // ---------------------------------------------------------------------------
  // Tab / Search
  // ---------------------------------------------------------------------------

  void selectTab(PairingHubTab tab) {
    state = state.copyWith(
      selectedTab: tab,
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query.trim(),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> acceptRequest(String pairingId) async {
    await sl<PairingRepository>().acceptPairRequest(pairingId);

    state = state.copyWith(
      selectedTab: PairingHubTab.paired,
    );
  }

  Future<void> rejectRequest(String pairingId) {
    return sl<PairingRepository>().rejectPairRequest(pairingId);
  }

  Future<void> cancelRequest(String pairingId) {
    return sl<PairingRepository>().cancelPairRequest(pairingId);
  }

  Future<void> disconnectPairing(String pairingId) {
    return sl<PairingRepository>().deletePairing(pairingId);
  }

  Future<void> deleteRequest(String pairingId) {
    return sl<PairingRepository>().deletePairing(pairingId);
  }

  // ---------------------------------------------------------------------------
  // Stream Handlers
  // ---------------------------------------------------------------------------

  void _onReceivedRequestsChanged(List<PairingEntity> items) {
    state = state.copyWith(
      isLoading: false,
      receivedRequests: items,
      errorMessage: null,
    );
  }

  void _onSentRequestsChanged(List<PairingEntity> items) {
    state = state.copyWith(
      isLoading: false,
      sentRequests: items,
      errorMessage: null,
    );
  }

  void _onPairedUsersChanged(List<PairingEntity> items) {
    state = state.copyWith(
      isLoading: false,
      pairedUsers: items,
      errorMessage: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  void _disposeSubscriptions() {
    _receivedSubscription?.cancel();
    _sentSubscription?.cancel();
    _pairedSubscription?.cancel();
  }
}