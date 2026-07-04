import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/pair_request_entity.dart';
import '../../domain/usecases/watch_incoming_pair_requests_usecase.dart';

final incomingPairRequestsProvider =
    StreamProvider.autoDispose<List<PairRequestEntity>>((ref) {
  final authRepository = sl<AuthRepository>();
  final currentUser = authRepository.currentUser;

  if (currentUser == null) {
    return const Stream<List<PairRequestEntity>>.empty();
  }

  final watchIncomingRequests = sl<WatchIncomingPairRequestsUseCase>();

  return watchIncomingRequests(currentUser.uid);
});