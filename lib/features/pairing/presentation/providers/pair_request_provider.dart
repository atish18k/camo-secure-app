// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pair_request_notifier.dart';
import 'pair_request_state.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final pairRequestProvider =
    NotifierProvider<PairRequestNotifier, PairRequestState>(
  PairRequestNotifier.new,
);