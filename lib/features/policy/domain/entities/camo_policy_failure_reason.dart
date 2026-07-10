// ---------------------------------------------------------------------------
// Policy Failure Reason
// ---------------------------------------------------------------------------

/// Describes why the CAMO Policy Engine denied an operation.
///
/// Existing enum values must not be renamed or reordered after persistence
/// begins. New reasons should be appended for backward compatibility.
enum CamoPolicyFailureReason {
  authenticationRequired,
  deviceMismatch,
  licenseExpired,
  pairNotAccepted,
  messageExpired,
  burned,
  deleted,
  revoked,
  blocked,
  policyVersionMismatch,
  policyViolation,
}