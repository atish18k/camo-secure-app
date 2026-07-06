// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/usecases/get_user_profile_usecase.dart';
import '../../domain/entities/pairing_entity.dart';
import '../../domain/usecases/create_pairing_usecase.dart';
import '../../domain/usecases/find_pairing_user_usecase.dart';
import '../../domain/usecases/get_pairing_usecase.dart';
import 'pair_request_state.dart';

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PairRequestNotifier extends Notifier<PairRequestState> {
  late final CreatePairingUseCase _createPairingUseCase;
  late final GetPairingUseCase _getPairingUseCase;
  late final FindPairingUserUseCase _findPairingUserUseCase;
  late final GetCurrentUserIdUseCase _getCurrentUserIdUseCase;
  late final GetUserProfileUseCase _getUserProfileUseCase;

  @override
  PairRequestState build() {
    _createPairingUseCase = sl<CreatePairingUseCase>();
    _getPairingUseCase = sl<GetPairingUseCase>();
    _findPairingUserUseCase = sl<FindPairingUserUseCase>();
    _getCurrentUserIdUseCase = sl<GetCurrentUserIdUseCase>();
    _getUserProfileUseCase = sl<GetUserProfileUseCase>();

    return const PairRequestState.initial();
  }

  Future<void> createPairRequest(PairingEntity pairing) async {
    state = const PairRequestState.loading();

    try {
      await _createPairingUseCase(pairing);
      state = const PairRequestState.sent();
    } catch (_) {
      state = const PairRequestState.failure(null);
    }
  }

  Future<void> createPairRequestByCamoId(String receiverCamoId) async {
    state = const PairRequestState.loading();

    try {
      final String? requesterUid = _getCurrentUserIdUseCase();

      if (requesterUid == null || requesterUid.isEmpty) {
        state = const PairRequestState.failure(null);
        return;
      }

      final UserEntity? requester =
          await _getUserProfileUseCase(requesterUid);

      if (requester == null) {
        state = const PairRequestState.failure(null);
        return;
      }

      final UserEntity? receiver =
          await _findPairingUserUseCase(receiverCamoId);

      if (receiver == null) {
        state = const PairRequestState.failure(null);
        return;
      }

      if (requester.uid == receiver.uid) {
        state = const PairRequestState.failure(null);
        return;
      }

      final DateTime now = DateTime.now();

      final PairingEntity pairing = PairingEntity(
        id: '${requester.uid}_${receiver.uid}',
        requesterUid: requester.uid,
        requesterCamoId: requester.camoId,
        receiverUid: receiver.uid,
        receiverCamoId: receiver.camoId,
        status: PairingStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await _createPairingUseCase(pairing);

      state = const PairRequestState.sent();
    } catch (_) {
      state = const PairRequestState.failure(null);
    }
  }

  Future<void> loadPairRequest(String pairingId) async {
    state = const PairRequestState.loading();

    try {
      final PairingEntity? pairing = await _getPairingUseCase(pairingId);

      if (pairing == null) {
        state = const PairRequestState.failure(null);
        return;
      }

      state = PairRequestState.loaded(pairing);
    } catch (_) {
      state = const PairRequestState.failure(null);
    }
  }

  void reset() {
    state = const PairRequestState.initial();
  }
}