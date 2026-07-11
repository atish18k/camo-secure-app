// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
abstract base class CamoFailure {
  const CamoFailure({required this.code, required this.message, this.cause});
  final String code;
  final String message;
  final Object? cause;
  @override
  String toString() {
    return 'CamoFailure(code: $code, message: $message, cause: $cause)';
  }
}

// -----------------------------------------------------------------------------
// Implementations
// -----------------------------------------------------------------------------
final class CamoUnexpectedFailure extends CamoFailure {
  const CamoUnexpectedFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}

final class CamoValidationFailure extends CamoFailure {
  const CamoValidationFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}

final class CamoSecurityFailure extends CamoFailure {
  const CamoSecurityFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}

final class CamoNetworkFailure extends CamoFailure {
  const CamoNetworkFailure({
    required super.code,
    required super.message,
    super.cause,
  });
}
