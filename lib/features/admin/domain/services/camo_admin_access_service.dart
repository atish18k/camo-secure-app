/// Resolves Admin Console UI eligibility.
///
/// This is a UI/navigation boundary only. Every future privileged operation
/// must be authorized again by a trusted backend.
abstract interface class CamoAdminAccessService {
  Future<bool> hasFreshAdminAccess();
}