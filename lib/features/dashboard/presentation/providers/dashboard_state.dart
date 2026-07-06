import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';

@immutable
class DashboardState {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const DashboardState({
    required this.displayName,
    required this.camoId,
    required this.isPaired,
    required this.isLoading,
    this.failure,
  });

  // ---------------------------------------------------------------------------
  // Factory Constructors
  // ---------------------------------------------------------------------------

  factory DashboardState.loading() {
    return const DashboardState(
      displayName: 'Loading...',
      camoId: 'CAMO-XXXX-XXXX',
      isPaired: false,
      isLoading: true,
    );
  }

  factory DashboardState.guest() {
    return const DashboardState(
      displayName: 'Guest User',
      camoId: 'Not Signed In',
      isPaired: false,
      isLoading: false,
    );
  }

  factory DashboardState.profileMissing() {
    return const DashboardState(
      displayName: 'CAMO User',
      camoId: 'Profile Not Found',
      isPaired: false,
      isLoading: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String displayName;
  final String camoId;
  final bool isPaired;
  final bool isLoading;
  final Failure? failure;

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------

  DashboardState copyWith({
    String? displayName,
    String? camoId,
    bool? isPaired,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return DashboardState(
      displayName: displayName ?? this.displayName,
      camoId: camoId ?? this.camoId,
      isPaired: isPaired ?? this.isPaired,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}