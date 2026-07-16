import 'camo_message_decode_decision.dart';
import 'camo_message_lifecycle_state.dart';
import 'camo_message_validity.dart';

final class CamoCanonicalMessageLifecycle {
  CamoCanonicalMessageLifecycle({
    required this.messageId,
    required this.pairId,
    required this.senderUserId,
    required this.senderDeviceId,
    required this.validity,
    required this.oneTimeView,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    this.consumedAt,
    this.revokedAt,
    this.deletedAt,
  }) {
    _validate();
  }

  static const int schemaVersion = 1;

  final String messageId;
  final String pairId;
  final String senderUserId;
  final String senderDeviceId;
  final CamoMessageValidity validity;
  final bool oneTimeView;
  final CamoMessageLifecycleState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final DateTime? consumedAt;
  final DateTime? revokedAt;
  final DateTime? deletedAt;

  bool isExpiredAt(DateTime serverTime) {
    _requireUtc(serverTime, 'serverTime');
    return expiresAt != null && !serverTime.isBefore(expiresAt!);
  }

  CamoMessageDecodeDecision evaluateDecodeAt(DateTime serverTime) {
    _requireUtc(serverTime, 'serverTime');
    if (isExpiredAt(serverTime)) {
      return const CamoMessageDecodeDecision.denied(
        CamoMessageDecodeDenialReason.expired,
      );
    }
    return switch (state) {
      CamoMessageLifecycleState.active =>
        const CamoMessageDecodeDecision.allowed(),
      CamoMessageLifecycleState.consumed =>
        const CamoMessageDecodeDecision.denied(
          CamoMessageDecodeDenialReason.consumed,
        ),
      CamoMessageLifecycleState.revoked =>
        const CamoMessageDecodeDecision.denied(
          CamoMessageDecodeDenialReason.revoked,
        ),
      CamoMessageLifecycleState.deleted =>
        const CamoMessageDecodeDecision.denied(
          CamoMessageDecodeDenialReason.deleted,
        ),
    };
  }

  bool permitsTransitionTo(CamoMessageLifecycleState next) {
    if (state != CamoMessageLifecycleState.active || next == state) {
      return false;
    }
    if (next == CamoMessageLifecycleState.consumed) {
      return oneTimeView;
    }
    return next == CamoMessageLifecycleState.revoked ||
        next == CamoMessageLifecycleState.deleted;
  }

  void _validate() {
    for (final value in <String>[
      messageId,
      pairId,
      senderUserId,
      senderDeviceId,
    ]) {
      if (value.isEmpty || value != value.trim() || value.contains('/')) {
        throw const FormatException(
          'Message lifecycle identifiers must be non-empty document-safe values.',
        );
      }
    }
    _requireUtc(createdAt, 'createdAt');
    _requireUtc(updatedAt, 'updatedAt');
    if (updatedAt.isBefore(createdAt)) {
      throw const FormatException('updatedAt cannot precede createdAt.');
    }
    for (final entry in <MapEntry<String, DateTime?>>[
      MapEntry<String, DateTime?>('expiresAt', expiresAt),
      MapEntry<String, DateTime?>('consumedAt', consumedAt),
      MapEntry<String, DateTime?>('revokedAt', revokedAt),
      MapEntry<String, DateTime?>('deletedAt', deletedAt),
    ]) {
      if (entry.value != null) _requireUtc(entry.value!, entry.key);
    }
    final duration = validity.duration;
    if (duration == null) {
      if (expiresAt != null) {
        throw const FormatException(
          'Unlimited validity cannot have expiresAt.',
        );
      }
    } else {
      final expectedExpiry = createdAt.add(duration);
      if (expiresAt == null || expiresAt != expectedExpiry) {
        throw const FormatException(
          'expiresAt must match the canonical validity window.',
        );
      }
    }
    final expectedTerminalTime = switch (state) {
      CamoMessageLifecycleState.active => null,
      CamoMessageLifecycleState.consumed => consumedAt,
      CamoMessageLifecycleState.revoked => revokedAt,
      CamoMessageLifecycleState.deleted => deletedAt,
    };
    if (state.isTerminal && expectedTerminalTime == null) {
      throw FormatException('${state.name} requires its lifecycle timestamp.');
    }
    if (state == CamoMessageLifecycleState.consumed && !oneTimeView) {
      throw const FormatException('Only one-time messages may be consumed.');
    }
    if (state != CamoMessageLifecycleState.consumed && consumedAt != null ||
        state != CamoMessageLifecycleState.revoked && revokedAt != null ||
        state != CamoMessageLifecycleState.deleted && deletedAt != null) {
      throw const FormatException(
        'Lifecycle timestamps must match the canonical terminal state.',
      );
    }
  }

  static void _requireUtc(DateTime value, String field) {
    if (!value.isUtc) {
      throw FormatException('$field must be UTC.');
    }
  }
}
