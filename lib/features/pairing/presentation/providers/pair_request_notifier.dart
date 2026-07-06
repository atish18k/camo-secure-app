// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/usecases/get_user_profile_usecase.dart';
import '../../domain/entities/pairing_entity.dart';
import '../../domain/usecases/accept_pair_request_usecase.dart';
import '../../domain/usecases/create_pairing_usecase.dart';
import '../../domain/usecases/find_pairing_user_usecase.dart';
import '../../domain/usecases/get_pairing_between_users_usecase.dart';
import '../../domain/usecases/get_pairing_usecase.dart';
import '../../domain/usecases/reject_pair_request_usecase.dart';
import 'pair_request_state.dart';

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PairRequestNotifier extends Notifier<PairRequestState> {
  late final CreatePairingUseCase _createPairingUseCase;
  late final GetPairingUseCase _getPairingUseCase;
  late final GetPairingBetweenUsersUseCase _getPairingBetweenUsersUseCase;
  late final FindPairingUserUseCase _findPairingUserUseCase;
  late final GetCurrentUserIdUseCase _getCurrentUserIdUseCase;
  late final GetUserProfileUseCase _getUserProfileUseCase;
  late final AcceptPairRequestUseCase _acceptPairRequestUseCase;
  late final RejectPairRequestUseCase _rejectPairRequestUseCase;

  @override
  PairRequestState build() {
    _createPairingUseCase = sl<CreatePairingUseCase>();
    _getPairingUseCase = sl<GetPairingUseCase>();
    _getPairingBetweenUsersUseCase = sl<GetPairingBetweenUsersUseCase>();
    _findPairingUserUseCase = sl<FindPairingUserUseCase>();
    _getCurrentUserIdUseCase = sl<GetCurrentUserIdUseCase>();
    _getUserProfileUseCase = sl<GetUserProfileUseCase>();
    _acceptPairRequestUseCase = sl<AcceptPairRequestUseCase>();
    _rejectPairRequestUseCase = sl<RejectPairRequestUseCase>();

    return const PairRequestState.initial();
  }

  Future<void> createPairRequest(PairingEntity pairing) async {
    state = const PairRequestState.loading();

    try {
      await _createPairingUseCase(pairing);
      state = const PairRequestState.sent();
    } on FormatException catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: error.message,
          cause: error,
        ),
      );
    } catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: 'Unable to create pair request. $error',
          cause: error,
        ),
      );
    }
  }

  Future<void> createPairRequestByCamoId(String receiverCamoId) async {
    state = const PairRequestState.loading();

    try {
      final String? requesterUid = _getCurrentUserIdUseCase();

      if (requesterUid == null || requesterUid.isEmpty) {
        state = const PairRequestState.failure(
          AuthFailure(
            message: 'Please login again to send a pair request.',
          ),
        );
        return;
      }

      final UserEntity? requester = await _getUserProfileUseCase(requesterUid);

      if (requester == null) {
        state = const PairRequestState.failure(
          AuthFailure(
            message: 'Unable to load your CAMO profile.',
          ),
        );
        return;
      }

      final UserEntity? receiver = await _findPairingUserUseCase(receiverCamoId);

      if (receiver == null) {
        state = const PairRequestState.failure(
          ValidationFailure(
            message: 'No CAMO user found with this CAMO ID.',
          ),
        );
        return;
      }

      if (requester.uid == receiver.uid) {
        state = const PairRequestState.failure(
          ValidationFailure(
            message: 'You cannot pair with yourself.',
          ),
        );
        return;
      }

      final PairingEntity? existingForward =
          await _getPairingBetweenUsersUseCase(
        requesterUid: requester.uid,
        receiverUid: receiver.uid,
      );

      final PairingEntity? existingReverse =
          await _getPairingBetweenUsersUseCase(
        requesterUid: receiver.uid,
        receiverUid: requester.uid,
      );

      final PairingEntity? existingPairing =
          existingForward ?? existingReverse;

      if (existingPairing != null) {
        switch (existingPairing.status) {
          case PairingStatus.pending:
            state = const PairRequestState.failure(
              PairingFailure(
                message: 'A pair request is already pending.',
              ),
            );
            return;

          case PairingStatus.accepted:
            state = const PairRequestState.failure(
              PairingFailure(
                message: 'You are already paired with this CAMO user.',
              ),
            );
            return;

          case PairingStatus.blocked:
            state = const PairRequestState.failure(
              PairingFailure(
                message: 'Pairing is not available for this CAMO user.',
              ),
            );
            return;

          case PairingStatus.rejected:
          case PairingStatus.cancelled:
          case PairingStatus.expired:
            break;
        }
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
    } on FormatException catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: error.message,
          cause: error,
        ),
      );
    } catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: 'Unable to send pair request. $error',
          cause: error,
        ),
      );
    }
  }

  Future<void> loadPairRequest(String pairingId) async {
    state = const PairRequestState.loading();

    try {
      final PairingEntity? pairing = await _getPairingUseCase(pairingId);

      if (pairing == null) {
        state = const PairRequestState.failure(
          PairingFailure(
            message: 'Pair request not found.',
          ),
        );
        return;
      }

      state = PairRequestState.loaded(pairing);
    } on FormatException catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: error.message,
          cause: error,
        ),
      );
    } catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: 'Unable to load pair request. $error',
          cause: error,
        ),
      );
    }
  }

  Future<void> acceptPairRequest(String pairingId) async {
    state = const PairRequestState.loading();

    try {
      await _acceptPairRequestUseCase(pairingId);
      state = const PairRequestState.sent();
    } on FormatException catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: error.message,
          cause: error,
        ),
      );
    } catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: 'Unable to accept pair request. $error',
          cause: error,
        ),
      );
    }
  }

  Future<void> rejectPairRequest(String pairingId) async {
    state = const PairRequestState.loading();

    try {
      await _rejectPairRequestUseCase(pairingId);
      state = const PairRequestState.sent();
    } on FormatException catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: error.message,
          cause: error,
        ),
      );
    } catch (error) {
      state = PairRequestState.failure(
        PairingFailure(
          message: 'Unable to reject pair request. $error',
          cause: error,
        ),
      );
    }
  }

  void reset() {
    state = const PairRequestState.initial();
  }
}