import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../pairing/domain/entities/pairing_entity.dart';
import '../../../pairing/domain/usecases/watch_accepted_pairings_usecase.dart';
import '../../../profile/domain/usecases/get_user_profile_usecase.dart';
import 'dashboard_state.dart';

final dashboardProvider = NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  late final GetCurrentUserIdUseCase _getCurrentUserIdUseCase;
  late final GetUserProfileUseCase _getUserProfileUseCase;
  late final WatchAcceptedPairingsUseCase _watchAcceptedPairingsUseCase;

  StreamSubscription<List<PairingEntity>>? _pairingsSubscription;

  @override
  DashboardState build() {
    _getCurrentUserIdUseCase = sl<GetCurrentUserIdUseCase>();
    _getUserProfileUseCase = sl<GetUserProfileUseCase>();
    _watchAcceptedPairingsUseCase = sl<WatchAcceptedPairingsUseCase>();

    ref.onDispose(() {
      _pairingsSubscription?.cancel();
    });

    Future<void>.microtask(loadDashboard);

    return DashboardState.loading();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, failure: null);

    try {
      final String? uid = _getCurrentUserIdUseCase();

      if (uid == null || uid.isEmpty) {
        state = DashboardState.guest();
        return;
      }

      final user = await _getUserProfileUseCase(uid);

      if (user == null) {
        state = DashboardState.profileMissing();
        return;
      }

      state = state.copyWith(
        displayName: user.displayName,
        camoId: user.camoId,
        isLoading: false,
        failure: null,
      );

      await _pairingsSubscription?.cancel();

      _pairingsSubscription = _watchAcceptedPairingsUseCase(uid).listen((
        pairings,
      ) {
        state = state.copyWith(isPaired: pairings.isNotEmpty);
      });
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        failure: const UnknownFailure(
          message: 'Failed to load dashboard data.',
        ),
      );
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }
}
