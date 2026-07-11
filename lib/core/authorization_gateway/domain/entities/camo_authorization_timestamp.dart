// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationTimestamp {
  const CamoAuthorizationTimestamp({
    required this.clientTime,
    required this.maximumClockSkew,
  });
  final DateTime clientTime;
  final Duration maximumClockSkew;
  bool isWithinAllowedSkew(DateTime serverTime) {
    final Duration difference = serverTime.difference(clientTime).abs();
    return difference <= maximumClockSkew;
  }
}
