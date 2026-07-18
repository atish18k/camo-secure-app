import 'package:camo/features/workspace/presentation/widgets/camo_workspace_terminology.dart';
import 'package:camo/shared/widgets/navigation/camo_tabs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps visible labels without changing internal operation tabs', () {
    expect(CamoWorkspaceTerminology.title(CamoWorkspaceTab.encoder), 'CAMO');
    expect(CamoWorkspaceTerminology.action(CamoWorkspaceTab.encoder), 'CAMO');
    expect(CamoWorkspaceTerminology.title(CamoWorkspaceTab.decoder), 'UNCAMO');
    expect(CamoWorkspaceTerminology.action(CamoWorkspaceTab.decoder), 'UNCAMO');
  });
}
