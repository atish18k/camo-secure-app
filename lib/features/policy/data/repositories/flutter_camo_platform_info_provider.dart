// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/foundation.dart';

import '../../domain/entities/camo_platform_info.dart';
import '../../domain/repositories/camo_platform_info_provider.dart';

// ---------------------------------------------------------------------------
// Flutter Platform Info Provider
// ---------------------------------------------------------------------------

/// Flutter implementation of the privacy-preserving CAMO platform provider.
///
/// This implementation uses Flutter runtime information only and does not read
/// hardware identifiers or other privacy-sensitive device information.
class FlutterCamoPlatformInfoProvider
    implements CamoPlatformInfoProvider {
  const FlutterCamoPlatformInfoProvider();

  @override
  CamoPlatformInfo getPlatformInfo() {
    if (kIsWeb) {
      return const CamoPlatformInfo(
        type: CamoPlatformType.web,
      );
    }

    final CamoPlatformType type = switch (defaultTargetPlatform) {
      TargetPlatform.android => CamoPlatformType.android,
      TargetPlatform.iOS => CamoPlatformType.ios,
      TargetPlatform.windows => CamoPlatformType.windows,
      TargetPlatform.linux => CamoPlatformType.linux,
      TargetPlatform.macOS => CamoPlatformType.macos,
      TargetPlatform.fuchsia => CamoPlatformType.fuchsia,
    };

    return CamoPlatformInfo(
      type: type,
    );
  }
}
