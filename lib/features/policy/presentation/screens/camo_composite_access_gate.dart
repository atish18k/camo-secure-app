import 'package:flutter/material.dart';
import '../../domain/services/camo_post_login_access_verifier.dart';

class CamoCompositeAccessGate extends StatefulWidget {
  const CamoCompositeAccessGate({
    required this.child,
    required this.verifier,
    super.key,
  });
  final Widget child;
  final CamoPostLoginAccessVerifier verifier;
  @override
  State<CamoCompositeAccessGate> createState() => _State();
}

class _State extends State<CamoCompositeAccessGate> {
  late Future<CamoPostLoginAccessDecision> check;
  @override
  void initState() {
    super.initState();
    check = widget.verifier.verify();
  }

  @override
  void didUpdateWidget(covariant CamoCompositeAccessGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.verifier, widget.verifier)) {
      check = widget.verifier.verify();
    }
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<CamoPostLoginAccessDecision>(
        future: check,
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!s.hasData || s.hasError || !s.data!.allowed) {
            return const Scaffold(
              body: Center(child: Text('Commercial access restricted')),
            );
          }
          return widget.child;
        },
      );
}
