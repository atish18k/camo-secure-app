// ---------------------------------------------------------------------------
// Policy Decision
// ---------------------------------------------------------------------------

/// Final decision returned by the CAMO Policy Engine.
///
/// The Crypto Engine must execute only when the decision is [allow].
enum CamoPolicyDecision {
  allow,
  deny,
}