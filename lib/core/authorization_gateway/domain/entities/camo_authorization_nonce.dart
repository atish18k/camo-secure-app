// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationNonce {
  const CamoAuthorizationNonce({required this.value, required this.createdAt});
  final String value;
  final DateTime createdAt;
  bool get isValid => value.isNotEmpty;
}
