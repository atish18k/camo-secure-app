// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import 'my_identity_state.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final myIdentityControllerProvider =
    NotifierProvider<MyIdentityController, MyIdentityState>(
  MyIdentityController.new,
);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class MyIdentityController extends Notifier<MyIdentityState> {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const Duration autoHideDuration = Duration(seconds: 5);
  static const Duration copyResetDuration = Duration(milliseconds: 500);

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  Timer? _autoHideTimer;
  Timer? _copyResetTimer;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  MyIdentityState build() {
    ref.onDispose(_disposeTimers);
    Future<void>.microtask(loadIdentity);
    return const MyIdentityState.initial();
  }

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadIdentity() async {
    final AuthRepository authRepository = sl<AuthRepository>();
    final ProfileRepository profileRepository = sl<ProfileRepository>();

    final String? uid = authRepository.currentUserId;

    if (uid == null || uid.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        displayName: 'Not Signed In',
        camoId: 'Not Signed In',
      );
      return;
    }

    final UserEntity? user = await profileRepository.getUser(uid);
    final String resolvedDisplayName = _resolveDisplayName(user);

    state = state.copyWith(
      isLoading: false,
      displayName: resolvedDisplayName,
      camoId: user?.camoId.trim().isNotEmpty == true
          ? user!.camoId
          : 'Profile Not Found',
    );
  }

  // ---------------------------------------------------------------------------
  // Visibility
  // ---------------------------------------------------------------------------

  void reveal() {
    if (!_hasValidCamoId(state.camoId)) {
      return;
    }

    state = state.copyWith(
      isVisible: true,
    );

    _restartAutoHideTimer();
  }

  void hide() {
    _autoHideTimer?.cancel();

    if (!state.isVisible) {
      return;
    }

    state = state.copyWith(
      isVisible: false,
    );
  }

  void toggleVisibility() {
    state.isVisible ? hide() : reveal();
  }

  // ---------------------------------------------------------------------------
  // Copy
  // ---------------------------------------------------------------------------

  Future<bool> copyCamoId() async {
    if (!_hasValidCamoId(state.camoId)) {
      return false;
    }

    await Clipboard.setData(
      ClipboardData(
        text: state.camoId,
      ),
    );

    _markCopied();

    return true;
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  void _restartAutoHideTimer() {
    _autoHideTimer?.cancel();

    _autoHideTimer = Timer(
      autoHideDuration,
      hide,
    );
  }

  void _markCopied() {
    _copyResetTimer?.cancel();

    state = state.copyWith(
      isCopied: true,
    );

    _copyResetTimer = Timer(
      copyResetDuration,
      () {
        state = state.copyWith(
          isCopied: false,
        );
      },
    );
  }

  bool _hasValidCamoId(String value) {
    final String trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return false;
    }

    switch (trimmedValue) {
      case 'CAMO-XXXX-XXXX':
      case 'Not Signed In':
      case 'Profile Not Found':
        return false;

      default:
        return true;
    }
  }

  String _resolveDisplayName(UserEntity? user) {
    final String? displayName = user?.displayName?.trim();

    if (displayName != null &&
        displayName.isNotEmpty &&
        displayName != 'CAMO User') {
      return displayName;
    }

    final String email = user?.email.trim() ?? '';

    if (email.contains('@')) {
      String name = email.split('@').first;

      name = name.replaceAll('.', ' ');
      name = name.replaceAll('_', ' ');
      name = name.replaceAll('-', ' ');

      if (name.trim().isNotEmpty) {
        return name.trim();
      }
    }

    return 'CAMO User';
  }

  void _disposeTimers() {
    _autoHideTimer?.cancel();
    _copyResetTimer?.cancel();
  }
}