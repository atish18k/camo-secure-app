// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../domain/entities/pairing_entity.dart';
import '../../domain/usecases/watch_accepted_pairings_usecase.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final acceptedPairingsProvider =
    StreamProvider<List<PairingEntity>>(
  (ref) {
    final GetCurrentUserIdUseCase getCurrentUserIdUseCase =
        sl<GetCurrentUserIdUseCase>();

    final WatchAcceptedPairingsUseCase watchAcceptedPairingsUseCase =
        sl<WatchAcceptedPairingsUseCase>();

    final String? currentUserId = getCurrentUserIdUseCase();

    if (currentUserId == null || currentUserId.isEmpty) {
      return const Stream<List<PairingEntity>>.empty();
    }

    return watchAcceptedPairingsUseCase(
      currentUserId,
    );
  },
);