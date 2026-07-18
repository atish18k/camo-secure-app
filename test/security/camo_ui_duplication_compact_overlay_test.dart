import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('duplication and compact overlay contract is explicit', () {
    final drawer = File(
      'lib/shared/widgets/navigation/camo_drawer.dart',
    ).readAsStringSync();
    final header = File(
      'lib/shared/widgets/header/camo_header.dart',
    ).readAsStringSync();
    final workspace = File(
      'lib/features/workspace/presentation/screens/workspace_screen.dart',
    ).readAsStringSync();
    final qr = File(
      'lib/features/dashboard/presentation/widgets/identity_qr_dialog.dart',
    ).readAsStringSync();
    final scanner = File(
      'lib/features/pairing/presentation/screens/qr_scanner_screen.dart',
    ).readAsStringSync();
    expect(drawer, isNot(contains("title: 'My Identity'")));
    expect(header, contains('Icons.person_add_alt_1_rounded'));
    expect(header, contains("'CAMO'"));
    expect(workspace, contains('showGeneralDialog<void>'));
    expect(workspace, contains('alignment: Alignment.topRight'));
    expect(workspace, contains('QrScannerScreen(compact: true)'));
    expect(qr, isNot(contains('SelectableText')));
    expect(qr, contains('CamoColors.primary'));
    expect(scanner, isNot(contains('CAMO ID')));
    expect(scanner, contains('border: Border.all(color: CamoColors.primary'));
    final drawerSource = File(
      'lib/shared/widgets/navigation/camo_drawer.dart',
    ).readAsStringSync();
    final inputSource = File(
      'lib/shared/widgets/workspace/camo_input_field.dart',
    ).readAsStringSync();
    final outputSource = File(
      'lib/shared/widgets/workspace/camo_output_field.dart',
    ).readAsStringSync();
    expect(drawerSource, isNot(contains('CamoColors.textPrimary')));
    expect(drawerSource, isNot(contains('CamoColors.textSecondary')));
    expect(drawerSource, contains('? CamoColors.error'));
    expect(inputSource, contains('CamoIcons.clear'));
    expect(outputSource, contains('CamoIcons.clear'));
    expect(
      inputSource.replaceAll('\r\n', '\n'),
      contains(
        'CamoIcons.clear,\n                    color: CamoColors.primary',
      ),
    );
    expect(
      outputSource.replaceAll('\r\n', '\n'),
      contains(
        'CamoIcons.clear,\n                    color: CamoColors.primary',
      ),
    );
  });
}
