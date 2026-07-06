// ---------------------------------------------------------------------------
// Pair Request Validator
// ---------------------------------------------------------------------------

class PairRequestValidator {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static final RegExp _camoIdPattern = RegExp(
    r'^CM-[A-Z0-9]{4}-[A-Z0-9]{4}$',
  );

  // ---------------------------------------------------------------------------
  // Validate
  // ---------------------------------------------------------------------------

  void validate({
    required String currentCamoId,
    required String targetCamoId,
  }) {
    // Empty
    if (targetCamoId.trim().isEmpty) {
      throw const FormatException(
        'CAMO ID cannot be empty.',
      );
    }

    // Format
    if (!_camoIdPattern.hasMatch(targetCamoId)) {
      throw const FormatException(
        'Invalid CAMO ID format.',
      );
    }

    // Self Pair
    if (currentCamoId == targetCamoId) {
      throw const FormatException(
        'You cannot pair with yourself.',
      );
    }
  }
}