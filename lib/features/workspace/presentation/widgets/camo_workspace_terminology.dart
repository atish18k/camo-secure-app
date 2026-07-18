import '../../../../../shared/widgets/navigation/camo_tabs.dart';

abstract final class CamoWorkspaceTerminology {
  static String title(CamoWorkspaceTab tab) =>
      tab == CamoWorkspaceTab.encoder ? 'CAMO' : 'UNCAMO';

  static String action(CamoWorkspaceTab tab) => title(tab);
}
