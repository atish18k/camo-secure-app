import 'package:camo/features/workspace/presentation/providers/workspace_state.dart';
import 'package:camo/features/workspace/presentation/widgets/camo_workspace_operation_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cases = <CamoWorkspaceOperationStatus, String>{
    CamoWorkspaceOperationStatus.ready: 'Ready',
    CamoWorkspaceOperationStatus.authorizing: 'Authorizing with server',
    CamoWorkspaceOperationStatus.processing: 'Processing authorized operation',
    CamoWorkspaceOperationStatus.success: 'Operation completed',
    CamoWorkspaceOperationStatus.failure: 'Operation failed',
    CamoWorkspaceOperationStatus.expired: 'Authorization expired',
    CamoWorkspaceOperationStatus.blocked: 'Operation blocked',
  };
  for (final entry in cases.entries) {
    testWidgets('renders honest accessible ${entry.key.name} state', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CamoWorkspaceOperationBanner(status: entry.key)),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
      expect(
        find.bySemanticsLabel('Workspace operation status: ${entry.value}'),
        findsOneWidget,
      );
      semantics.dispose();
    });
  }

  test('workspace state preserves explicit operation status', () {
    final state = const WorkspaceState().copyWith(
      isLoading: true,
      operationStatus: CamoWorkspaceOperationStatus.authorizing,
    );
    expect(state.isLoading, isTrue);
    expect(state.operationStatus, CamoWorkspaceOperationStatus.authorizing);
  });
}
