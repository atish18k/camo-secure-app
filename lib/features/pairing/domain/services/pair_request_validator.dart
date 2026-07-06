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
    final String current = currentCamoId.trim().toUpperCase();
    final String target = targetCamoId.trim().toUpperCase();

    // Empty
    if (target.isEmpty) {
      throw const FormatException(
        'CAMO ID cannot be empty.',
      );
    }

    // Format
    if (!_camoIdPattern.hasMatch(target)) {
      throw const FormatException(
        'Invalid CAMO ID format.',
      );
    }

    // Self Pair
    if (current == target) {
      throw const FormatException(
        'You cannot pair with yourself.',
      );
    }
  }
}