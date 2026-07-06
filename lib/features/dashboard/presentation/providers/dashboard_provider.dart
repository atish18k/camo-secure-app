import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../profile/domain/usecases/get_user_profile_usecase.dart';
import 'dashboard_state.dart';

final dashboardProvider =
    NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  late final GetCurrentUserIdUseCase _getCurrentUserIdUseCase;
  late final GetUserProfileUseCase _getUserProfileUseCase;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  DashboardState build() {
    _getCurrentUserIdUseCase = sl<GetCurrentUserIdUseCase>();
    _getUserProfileUseCase = sl<GetUserProfileUseCase>();

    Future<void>.microtask(loadDashboard);

    return DashboardState.loading();
  }

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  Future<void> loadDashboard() async {
    state = state.copyWith(
      isLoading: true,
      failure: null,
    );

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
        isPaired: false,
        isLoading: false,
        failure: null,
      );
    } catch (error, stackTrace) {
      debugPrint('DASHBOARD: Load failed -> $error');
      debugPrintStack(stackTrace: stackTrace);

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