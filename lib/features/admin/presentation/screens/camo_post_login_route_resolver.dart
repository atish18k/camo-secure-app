import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../data/services/firebase_camo_admin_access_service.dart';
import '../../domain/services/camo_admin_access_service.dart';

/// Resolves the first route after normal authentication.
///
/// Authorized admin:
///   fresh camoAdmin=true + locked identity -> Admin Console
///
/// Every other authenticated user:
///   existing dashboard route -> exact-device approval -> composite access
class CamoPostLoginRouteResolver extends StatefulWidget {
  const CamoPostLoginRouteResolver({
    super.key,
    this.adminAccessService,
  });

  final CamoAdminAccessService? adminAccessService;

  @override
  State<CamoPostLoginRouteResolver> createState() =>
      _CamoPostLoginRouteResolverState();
}

class _CamoPostLoginRouteResolverState
    extends State<CamoPostLoginRouteResolver> {
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final bool isAdmin =
        await (widget.adminAccessService ??
                FirebaseCamoAdminAccessService())
            .hasFreshAdminAccess();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      isAdmin ? AppRoutes.adminConsole : AppRoutes.dashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}