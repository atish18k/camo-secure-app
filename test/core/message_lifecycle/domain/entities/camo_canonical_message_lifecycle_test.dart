import 'package:camo/core/message_lifecycle/domain/entities/camo_canonical_message_lifecycle.dart';
import 'package:camo/core/message_lifecycle/domain/entities/camo_message_decode_decision.dart';
import 'package:camo/core/message_lifecycle/domain/entities/camo_message_lifecycle_state.dart';
import 'package:camo/core/message_lifecycle/domain/entities/camo_message_validity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime.utc(2026, 7, 17, 0);

  CamoCanonicalMessageLifecycle build({
    CamoMessageValidity validity = CamoMessageValidity.fiveMinutes,
    bool oneTimeView = false,
    CamoMessageLifecycleState state = CamoMessageLifecycleState.active,
    DateTime? consumedAt,
    DateTime? revokedAt,
    DateTime? deletedAt,
  }) {
    return CamoCanonicalMessageLifecycle(
      messageId: 'message-1',
      pairId: 'pair-1',
      senderUserId: 'user-1',
      senderDeviceId: 'device-1',
      validity: validity,
      oneTimeView: oneTimeView,
      state: state,
      createdAt: createdAt,
      updatedAt: consumedAt ?? revokedAt ?? deletedAt ?? createdAt,
      expiresAt: validity.duration == null
          ? null
          : createdAt.add(validity.duration!),
      consumedAt: consumedAt,
      revokedAt: revokedAt,
      deletedAt: deletedAt,
    );
  }

  test('locks the canonical schema and validity options', () {
    expect(CamoCanonicalMessageLifecycle.schemaVersion, 1);
    expect(CamoMessageValidity.values, hasLength(6));
    expect(CamoMessageValidity.unlimited.duration, isNull);
    expect(CamoMessageValidity.oneDay.duration, const Duration(days: 1));
  });

  test('server time denies decode at the expiry boundary', () {
    final policy = build();
    expect(
      policy
          .evaluateDecodeAt(createdAt.add(const Duration(minutes: 5)))
          .denialReason,
      CamoMessageDecodeDenialReason.expired,
    );
  });

  test('active unexpired message permits decode', () {
    final decision = build().evaluateDecodeAt(
      createdAt.add(const Duration(minutes: 4)),
    );
    expect(decision.allowed, isTrue);
  });

  test('consumed one-time message denies decode', () {
    final consumedAt = createdAt.add(const Duration(minutes: 1));
    final decision = build(
      oneTimeView: true,
      state: CamoMessageLifecycleState.consumed,
      consumedAt: consumedAt,
    ).evaluateDecodeAt(consumedAt);
    expect(decision.denialReason, CamoMessageDecodeDenialReason.consumed);
  });

  test('revoked and deleted terminal states deny decode', () {
    final terminalAt = createdAt.add(const Duration(minutes: 1));
    expect(
      build(
        state: CamoMessageLifecycleState.revoked,
        revokedAt: terminalAt,
      ).evaluateDecodeAt(terminalAt).denialReason,
      CamoMessageDecodeDenialReason.revoked,
    );
    expect(
      build(
        state: CamoMessageLifecycleState.deleted,
        deletedAt: terminalAt,
      ).evaluateDecodeAt(terminalAt).denialReason,
      CamoMessageDecodeDenialReason.deleted,
    );
  });

  test('terminal transitions are one-way and consumption is one-time only', () {
    expect(
      build(
        oneTimeView: true,
      ).permitsTransitionTo(CamoMessageLifecycleState.consumed),
      isTrue,
    );
    expect(
      build().permitsTransitionTo(CamoMessageLifecycleState.consumed),
      isFalse,
    );
    final terminalAt = createdAt.add(const Duration(minutes: 1));
    expect(
      build(
        state: CamoMessageLifecycleState.revoked,
        revokedAt: terminalAt,
      ).permitsTransitionTo(CamoMessageLifecycleState.active),
      isFalse,
    );
  });

  test('invalid expiry and lifecycle timestamp combinations fail closed', () {
    expect(
      () => CamoCanonicalMessageLifecycle(
        messageId: 'message-1',
        pairId: 'pair-1',
        senderUserId: 'user-1',
        senderDeviceId: 'device-1',
        validity: CamoMessageValidity.unlimited,
        oneTimeView: false,
        state: CamoMessageLifecycleState.active,
        createdAt: createdAt,
        updatedAt: createdAt,
        expiresAt: createdAt.add(const Duration(days: 1)),
      ),
      throwsFormatException,
    );
    expect(
      () => build(
        state: CamoMessageLifecycleState.consumed,
        consumedAt: createdAt.add(const Duration(minutes: 1)),
      ),
      throwsFormatException,
    );
  });
}
