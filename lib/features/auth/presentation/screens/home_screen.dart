// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/header/camo_header.dart';
import '../../../../shared/widgets/navigation/camo_drawer.dart';
import '../../../../shared/widgets/navigation/camo_tabs.dart';
import '../../../../shared/widgets/workspace/camo_action_button.dart';
import '../../../../shared/widgets/workspace/camo_camouflage_switch.dart';
import '../../../../shared/widgets/workspace/camo_input_field.dart';
import '../../../../shared/widgets/workspace/camo_output_field.dart';
import '../../../../shared/widgets/workspace/camo_pair_selector.dart';
import '../../../../shared/widgets/workspace/camo_subject_field.dart';
import '../../../../shared/widgets/workspace/camo_workspace_box.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../pairing/domain/entities/pairing_entity.dart';
import '../../../pairing/presentation/providers/accepted_pairings_provider.dart';
import '../../../workspace/presentation/providers/workspace_controller.dart';

// ---------------------------------------------------------------------------
// Home Screen
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  CamoWorkspaceTab _selectedTab = CamoWorkspaceTab.encoder;
  PairingEntity? _selectedPair;
  CamoPairStatus _selectedPairStatus = CamoPairStatus.offline;
  bool _isCamouflageEnabled = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_refresh);
  }

  @override
  void dispose() {
    _inputController.removeListener(_refresh);
    _subjectController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(workspaceControllerProvider);
    final acceptedPairings = ref.watch(acceptedPairingsProvider);

    final bool canRun = _selectedPair != null &&
        _inputController.text.trim().isNotEmpty &&
        !workspaceState.isLoading;

    return Scaffold(
      backgroundColor: CamoColors.background,
      drawer: CamoDrawer(
        onWorkspaceTap: _closeDrawer,
        onMyIdentityTap: _closeDrawerAndShowComingSoon,
        onMyPairingsTap: _openMyPairings,
        onSecurityCenterTap: _closeDrawerAndShowComingSoon,
        onSettingsTap: _closeDrawerAndShowComingSoon,
        onAboutTap: _closeDrawerAndShowComingSoon,
        onLogoutTap: _closeDrawerAndShowComingSoon,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (BuildContext context) {
                return CamoHeader(
                  pendingCount: 1,
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onPairTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.pairRequest,
                  ),
                  onPendingTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.pendingPairRequests,
                  ),
                  onScanQrTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.qrScanner,
                  ),
                  onSentTap: _showComingSoon,
                );
              },
            ),
            Expanded(
              child: ResponsiveContainer(
                child: SingleChildScrollView(
                  padding: CamoSpacing.screen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPairSelector(acceptedPairings),
                      CamoSpacing.gapLg,
                      CamoTabs(
                        selectedTab: _selectedTab,
                        onChanged: _onTabChanged,
                      ),
                      CamoSpacing.gapLg,
                      CamoWorkspaceBox(
                        title: _selectedTab == CamoWorkspaceTab.encoder
                            ? 'Encoder'
                            : 'Decoder',
                        child: _buildWorkspaceContent(canRun),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPairSelector(
    AsyncValue<List<PairingEntity>> acceptedPairings,
  ) {
    return Center(
      child: CamoPairSelector(
        selectedPairLabel: _selectedPairLabel,
        status: _selectedPairStatus,
        onTap: () => _showPairSelectionSheet(acceptedPairings),
      ),
    );
  }

  Widget _buildWorkspaceContent(bool canRun) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CamoCamouflageSwitch(
          value: _isCamouflageEnabled,
          onChanged: _toggleCamouflage,
        ),
        if (_isCamouflageEnabled) ...[
          CamoSpacing.gapLg,
          CamoSubjectField(
            controller: _subjectController,
          ),
        ],
        CamoSpacing.gapLg,
        CamoInputField(
          controller: _inputController,
          onPasteTap: _pasteInput,
          onClearTap: _clearInput,
        ),
        CamoSpacing.gapLg,
        CamoActionButton(
          label: _selectedTab == CamoWorkspaceTab.encoder
              ? 'Encode'
              : 'Decode',
          icon: _selectedTab == CamoWorkspaceTab.encoder
              ? CamoIcons.encode
              : CamoIcons.decode,
          onPressed: canRun ? _runWorkspaceAction : null,
        ),
        CamoSpacing.gapLg,
        CamoOutputField(
          controller: _outputController,
          onCopyTap: _copyOutput,
          onShareTap: _shareOutput,
          onClearTap: _clearOutput,
        ),
      ],
    );
  }

  Widget _buildPairOption({
    required PairingEntity pairing,
  }) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: CamoColors.background,
        child: Icon(
          CamoIcons.profile,
          color: CamoColors.primary,
        ),
      ),
      title: Text(_pairLabel(pairing)),
      subtitle: Text(_pairCamoId(pairing)),
      trailing: const _PairStatusDot(status: CamoPairStatus.online),
      onTap: () {
        Navigator.pop(context);

        setState(() {
          _selectedPair = pairing;
          _selectedPairStatus = CamoPairStatus.online;
          _outputController.clear();
        });
      },
    );
  }

  void _onTabChanged(CamoWorkspaceTab tab) {
    setState(() {
      _selectedTab = tab;
      _outputController.clear();
    });
  }

  void _toggleCamouflage(bool value) {
    setState(() {
      _isCamouflageEnabled = value;

      if (!value) {
        _subjectController.clear();
      }
    });
  }

  Future<void> _showPairSelectionSheet(
    AsyncValue<List<PairingEntity>> acceptedPairings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: CamoColors.surface,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: CamoSpacing.screen,
            child: acceptedPairings.when(
              data: (List<PairingEntity> pairings) {
                if (pairings.isEmpty) {
                  return _buildEmptyPairSheet();
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Pair',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    CamoSpacing.gapMd,
                    ...pairings.map(
                      (PairingEntity pairing) => _buildPairOption(
                        pairing: pairing,
                      ),
                    ),
                    CamoSpacing.gapSm,
                    _buildNewPairButton(),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => _buildPairErrorSheet(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyPairSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No active pairings found.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        CamoSpacing.gapMd,
        _buildNewPairButton(),
      ],
    );
  }

  Widget _buildPairErrorSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Unable to load pairings.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        CamoSpacing.gapMd,
        _buildNewPairButton(),
      ],
    );
  }

  Widget _buildNewPairButton() {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          AppRoutes.pairRequest,
        );
      },
      icon: const Icon(CamoIcons.pair),
      label: const Text('New Pair'),
    );
  }

  Future<void> _pasteInput() async {
    final ClipboardData? data = await Clipboard.getData(
      Clipboard.kTextPlain,
    );

    final String text = data?.text ?? '';

    if (text.isEmpty) {
      return;
    }

    _inputController.text = text;
  }

  void _clearInput() {
    _inputController.clear();
  }

  void _clearOutput() {
    _outputController.clear();
    ref.read(workspaceControllerProvider.notifier).clearOutput();
  }

  Future<void> _copyOutput() async {
    final String text = _outputController.text.trim();

    if (text.isEmpty) {
      _showMessage('No output to copy.');
      return;
    }

    await Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );

    _showMessage('Output copied.');
  }

  void _shareOutput() {
    _showComingSoon();
  }

  Future<void> _runWorkspaceAction() async {
    final String input = _inputController.text.trim();

    if (input.isEmpty || _selectedPair == null) {
      return;
    }

    final workspaceController =
        ref.read(workspaceControllerProvider.notifier);

    if (_selectedTab == CamoWorkspaceTab.encoder) {
      await workspaceController.encode(
        pairingId: _selectedPair!.id,
        plainText: input,
        subject: _isCamouflageEnabled
            ? _subjectController.text.trim()
            : null,
        camouflageEnabled: _isCamouflageEnabled,
      );
    } else {
      await workspaceController.decode(
        pairingId: _selectedPair!.id,
        encodedText: input,
      );
    }

    final workspaceState = ref.read(workspaceControllerProvider);

    if (workspaceState.errorMessage != null) {
      _showMessage(workspaceState.errorMessage!);
      return;
    }

    _outputController.text = workspaceState.output;
  }

  void _closeDrawer() {
    Navigator.pop(context);
  }

  void _closeDrawerAndShowComingSoon() {
    Navigator.pop(context);
    _showComingSoon();
  }

  void _openMyPairings() {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      AppRoutes.myPairings,
    );
  }

  void _showComingSoon() {
    _showMessage('This feature will be available soon.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String get _selectedPairLabel {
    if (_selectedPair == null) {
      return '';
    }

    return _pairLabel(_selectedPair!);
  }

  String _pairLabel(PairingEntity pairing) {
    return _pairCamoId(pairing);
  }

  String _pairCamoId(PairingEntity pairing) {
    final String? currentUserId = sl<GetCurrentUserIdUseCase>()();

    if (currentUserId == pairing.requesterUid) {
      return pairing.receiverCamoId;
    }

    return pairing.requesterCamoId;
  }

  void _refresh() {
    setState(() {});
  }
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _PairStatusDot extends StatelessWidget {
  const _PairStatusDot({
    required this.status,
  });

  final CamoPairStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _statusColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case CamoPairStatus.online:
        return CamoColors.success;

      case CamoPairStatus.away:
        return CamoColors.warning;

      case CamoPairStatus.offline:
        return CamoColors.error;
    }
  }
}