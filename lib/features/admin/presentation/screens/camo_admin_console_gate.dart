import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../data/services/firebase_camo_admin_access_service.dart';
import '../../domain/services/camo_admin_access_service.dart';
import 'camo_admin_console_screen.dart';

/// Independent route-level guard for Admin Console.
///
/// It intentionally does not consult ordinary-user device binding. It does
/// require a fresh token and locked admin identity on every route entry.
class CamoAdminConsoleGate extends StatefulWidget {
  const CamoAdminConsoleGate({
    super.key,
    this.adminAccessService,
  });

  final CamoAdminAccessService? adminAccessService;

  @override
  State<CamoAdminConsoleGate> createState() => _CamoAdminConsoleGateState();
}

class _CamoAdminConsoleGateState extends State<CamoAdminConsoleGate> {
  late final Future<bool> _verification;

  @override
  void initState() {
    super.initState();
    _verification =
        (widget.adminAccessService ?? FirebaseCamoAdminAccessService())
            .hasFreshAdminAccess();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _verification,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != true) {
          return Scaffold(
            appBar: AppBar(title: const Text('Access denied')),
            body: Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Return to login'),
              ),
            ),
          );
        }

        return const CamoAdminConsoleScreen();
      },
    );
  }
}