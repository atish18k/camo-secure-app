import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/enums/pair_request_status.dart' as pair_status;
import '../../../../core/errors/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/domain/usecases/get_user_by_camo_id_usecase.dart';
import '../../domain/entities/pair_request_entity.dart';
import '../../domain/usecases/get_pair_request_usecase.dart';
import '../../domain/usecases/send_pair_request_usecase.dart';
import 'pair_request_state.dart';

final pairRequestControllerProvider =
    NotifierProvider<PairRequestController, PairRequestState>(
  PairRequestController.new,
);

class PairRequestController extends Notifier<PairRequestState> {
  @override
  PairRequestState build() {
    return const PairRequestState.initial();
  }

  Future<void> sendPairRequestByCamoId(String camoId) async {
    state = const PairRequestState.loading();

    try {
      final authRepository = sl<AuthRepository>();
      final getUserByCamoIdUseCase = sl<GetUserByCamoIdUseCase>();

      final currentUser = authRepository.currentUser;

      if (currentUser == null) {
        state = const PairRequestState.failure(
          AuthFailure(
            message: 'You must be logged in to send a pair request.',
          ),
        );
        return;
      }

      final receiver = await getUserByCamoIdUseCase(camoId);

      if (receiver == null) {
        state = const PairRequestState.failure(
          PairingFailure(
            message: 'No CAMO user found with this ID.',
          ),
        );
        return;
      }

      if (receiver.uid == currentUser.uid) {
        state = const PairRequestState.failure(
          PairingFailure(
            message: 'You cannot send a pair request to yourself.',
          ),
        );
        return;
      }

      final now = DateTime.now();

      final request = PairRequestEntity(
        id: '${currentUser.uid}_${receiver.uid}_${now.millisecondsSinceEpoch}',
        senderUid: currentUser.uid,
        receiverUid: receiver.uid,
        createdAt: now,
        status: pair_status.PairRequestStatus.pending,
      );

      await sendPairRequest(request);
    } catch (e, stackTrace) {
      debugPrint('PAIR_REQUEST: Send by CAMO ID exception -> $e');
      debugPrintStack(stackTrace: stackTrace);

      state = const PairRequestState.failure(
        PairingFailure(
          message: 'Failed to send pair request. Please try again.',
        ),
      );
    }
  }

  Future<void> sendPairRequest(PairRequestEntity request) async {
    state = const PairRequestState.loading();

    try {
      final sendPairRequestUseCase = sl<SendPairRequestUseCase>();

      await sendPairRequestUseCase(request);

      state = const PairRequestState.sent();
    } catch (e, stackTrace) {
      debugPrint('PAIR_REQUEST: Send exception -> $e');
      debugPrintStack(stackTrace: stackTrace);

      state = const PairRequestState.failure(
        PairingFailure(
          message: 'Failed to send pair request. Please try again.',
        ),
      );
    }
  }

  Future<void> getPairRequest(String id) async {
    state = const PairRequestState.loading();

    try {
      final getPairRequestUseCase = sl<GetPairRequestUseCase>();

      final request = await getPairRequestUseCase(id);

      state = PairRequestState.loaded(request);
    } catch (e, stackTrace) {
      debugPrint('PAIR_REQUEST: Get exception -> $e');
      debugPrintStack(stackTrace: stackTrace);

      state = const PairRequestState.failure(
        PairingFailure(
          message: 'Failed to load pair request. Please try again.',
        ),
      );
    }
  }

  void reset() {
    state = const PairRequestState.initial();
  }
}