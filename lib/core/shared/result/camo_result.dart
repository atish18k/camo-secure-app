// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../failures/camo_failure.dart';

// -----------------------------------------------------------------------------
// Sealed Result
// -----------------------------------------------------------------------------
sealed class CamoResult<T> {
  const CamoResult();
  bool get isSuccess;
  bool get isFailure => !isSuccess;
  T? get valueOrNull;
  CamoFailure? get failureOrNull;
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(CamoFailure failure) onFailure,
  });
}

// -----------------------------------------------------------------------------
// Success
// -----------------------------------------------------------------------------
final class CamoSuccess<T> extends CamoResult<T> {
  const CamoSuccess(this.value);
  final T value;
  @override
  bool get isSuccess => true;
  @override
  T get valueOrNull => value;
  @override
  CamoFailure? get failureOrNull => null;
  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(CamoFailure failure) onFailure,
  }) {
    return onSuccess(value);
  }
}

// -----------------------------------------------------------------------------
// Failure
// -----------------------------------------------------------------------------
final class CamoError<T> extends CamoResult<T> {
  const CamoError(this.failure);
  final CamoFailure failure;
  @override
  bool get isSuccess => false;
  @override
  T? get valueOrNull => null;
  @override
  CamoFailure get failureOrNull => failure;
  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(CamoFailure failure) onFailure,
  }) {
    return onFailure(failure);
  }
}
