// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/result.dart' as app_result;
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_icons.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../../shared/widgets/header/camo_header.dart';
import '../../../../shared/widgets/identity/camo_identity_panel.dart';
import '../../../../shared/widgets/navigation/camo_drawer.dart';
import '../../../../shared/widgets/navigation/camo_tabs.dart';
import '../../../../shared/widgets/workspace/camo_action_button.dart';
import '../../../../shared/widgets/workspace/camo_camouflage_switch.dart';
import '../../../../shared/widgets/workspace/camo_input_field.dart';
import '../../../../shared/widgets/workspace/camo_output_field.dart';
import '../../../../shared/widgets/workspace/camo_subject_field.dart';
import '../../../../shared/widgets/workspace/camo_workspace_box.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../../pairing/domain/entities/pairing_entity.dart';
import '../../../pairing/presentation/providers/accepted_pairings_provider.dart';
import '../../../pairing/presentation/providers/pending_pair_requests_provider.dart';
import '../../../pairing/presentation/screens/pending_pair_requests_screen.dart';
import '../../../notifications/domain/entities/camo_notification_feed.dart';
import '../../../notifications/presentation/providers/other_notifications_provider.dart';
import '../../../notifications/presentation/screens/other_notifications_panel.dart';
import '../../../dashboard/presentation/widgets/identity_qr_dialog.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/presentation/providers/my_identity_controller.dart';
import '../../../profile/presentation/providers/my_identity_state.dart';
import '../providers/workspace_controller.dart';
import '../widgets/workspace_pair_header.dart';

// ---------------------------------------------------------------------------
// Workspace Screen
// ---------------------------------------------------------------------------

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  CamoWorkspaceTab _selectedTab = CamoWorkspaceTab.encoder;
  PairingEntity? _selectedPair;
  bool _isCamouflageEnabled = false;
  bool _routePairLoaded = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_refresh);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routePairLoaded) {
      return;
    }

    final Object? arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is PairingEntity) {
      _selectedPair = arguments;
    }

    _routePairLoaded = true;
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
    final pendingRequests = ref.watch(pendingPairRequestsProvider);
    final AsyncValue<CamoNotificationFeed> notifications = ref.watch(
      otherNotificationsProvider,
    );
    final int pairRequestsCount = pendingRequests.when(
      data: (List<PairingEntity> items) => items.length,
      loading: () => 0,
      error: (_, _) => 0,
    );
    final int notificationCount = notifications.when(
      data: (CamoNotificationFeed feed) => feed.unreadCount,
      loading: () => 0,
      error: (_, _) => 0,
    );

    final bool canRun =
        _selectedPair != null &&
        _inputController.text.trim().isNotEmpty &&
        !workspaceState.isLoading;

    return Scaffold(
      backgroundColor: CamoColors.background,
      drawer: CamoDrawer(
        onWorkspaceTap: _closeDrawer,
        onMyIdentityTap: _openMyIdentity,
        onPairingHubTap: _openPairingHub,
        onHistoryTap: _closeDrawerAndShowComingSoon,
        onSecurityCenterTap: _closeDrawerAndShowComingSoon,
        onSettingsTap: _closeDrawerAndShowComingSoon,
        onAboutTap: _closeDrawerAndShowComingSoon,
        onLogoutTap: _logout,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (BuildContext context) {
                return CamoHeader(
                  pairRequestsCount: pairRequestsCount,
                  notificationCount: notificationCount,
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onPairRequestsTap: _showPendingPairRequestsPanel,
                  onNotificationsTap: _showOtherNotificationsPanel,
                  onScanQrTap: () =>
                      Navigator.pushNamed(context, AppRoutes.qrScanner),
                  onIdentityTap: _showIdentityPanel,
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

  Widget _buildPairSelector(AsyncValue<List<PairingEntity>> acceptedPairings) {
    if (_selectedPair == null) {
      return WorkspacePairHeader(
        displayName: '',
        camoId: '',
        onTap: () => _showPairSelectionSheet(acceptedPairings),
      );
    }

    return FutureBuilder<UserEntity?>(
      future: _loadRemoteUser(_selectedPair!),
      builder: (BuildContext context, AsyncSnapshot<UserEntity?> snapshot) {
        final String camoId = _pairCamoId(_selectedPair!);

        return WorkspacePairHeader(
          displayName: _resolveDisplayName(snapshot.data),
          camoId: camoId,
          onTap: () => _showPairSelectionSheet(acceptedPairings),
          onCopyTap: () => _copySelectedPairCamoId(camoId),
        );
      },
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
          CamoSubjectField(controller: _subjectController),
        ],
        CamoSpacing.gapLg,
        CamoInputField(
          controller: _inputController,
          onPasteTap: _pasteInput,
          onClearTap: _clearInput,
        ),
        CamoSpacing.gapLg,
        CamoActionButton(
          label: _selectedTab == CamoWorkspaceTab.encoder ? 'Encode' : 'Decode',
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

  Widget _buildPairOption({required PairingEntity pairing}) {
    return FutureBuilder<UserEntity?>(
      future: _loadRemoteUser(pairing),
      builder: (BuildContext context, AsyncSnapshot<UserEntity?> snapshot) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: CamoColors.background,
            child: Icon(CamoIcons.profile, color: CamoColors.primary),
          ),
          title: Text(_resolveDisplayName(snapshot.data)),
          subtitle: Text(_pairCamoId(pairing)),
          onTap: () {
            Navigator.pop(context);

            setState(() {
              _selectedPair = pairing;
              _outputController.clear();
            });
          },
        );
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

  Future<void> _showPendingPairRequestsPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: CamoColors.surface,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.78,
          child: PendingPairRequestsScreen(embedded: true),
        );
      },
    );
  }

  Future<void> _showOtherNotificationsPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: CamoColors.surface,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.78,
          child: OtherNotificationsPanel(),
        );
      },
    );
  }

  Future<void> _showIdentityPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: CamoColors.surface,
      builder: (BuildContext context) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final MyIdentityState state = ref.watch(
              myIdentityControllerProvider,
            );
            final controller = ref.read(myIdentityControllerProvider.notifier);
            final accepted = ref.watch(acceptedPairingsProvider);
            final bool isPaired = accepted.when(
              data: (List<PairingEntity> items) => items.isNotEmpty,
              loading: () => false,
              error: (_, _) => false,
            );
            return Padding(
              padding: CamoSpacing.screen,
              child: CamoIdentityPanel(
                camoId: state.camoId,
                isVisible: state.isVisible,
                isPaired: isPaired,
                onVisibilityTap: controller.toggleVisibility,
                onCopyTap: () async {
                  final bool copied = await controller.copyCamoId();
                  if (copied && mounted) {
                    _showMessage('CAMO ID copied.');
                  }
                },
                onQrTap: () {
                  if (state.camoId.trim().isEmpty) {
                    return;
                  }
                  showDialog<void>(
                    context: context,
                    builder: (_) => IdentityQrDialog(camoId: state.camoId),
                  );
                },
              ),
            );
          },
        );
      },
    );
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
                      (PairingEntity pairing) =>
                          _buildPairOption(pairing: pairing),
                    ),
                    CamoSpacing.gapSm,
                    _buildNewPairButton(),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
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
        Navigator.pushNamed(context, AppRoutes.pairRequest);
      },
      icon: const Icon(CamoIcons.pair),
      label: const Text('New Pair'),
    );
  }

  Future<void> _pasteInput() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);

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

  Future<void> _copySelectedPairCamoId(String camoId) async {
    if (camoId.trim().isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: camoId));

    _showMessage('CAMO ID copied.');
  }

  Future<void> _copyOutput() async {
    final String text = _outputController.text.trim();

    if (text.isEmpty) {
      _showMessage('No output to copy.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));

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

    final workspaceController = ref.read(workspaceControllerProvider.notifier);

    if (_selectedTab == CamoWorkspaceTab.encoder) {
      await workspaceController.encode(
        pairingId: _selectedPair!.id,
        plainText: input,
        subject: _isCamouflageEnabled ? _subjectController.text.trim() : null,
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

  void _openMyIdentity() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.myIdentity);
  }

  void _openPairingHub() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.myPairings);
  }

  Future<void> _logout() async {
    Navigator.pop(context);

    final AuthRepository authRepository = sl<AuthRepository>();
    final app_result.Result<void> result = await authRepository.signOut();

    switch (result) {
      case app_result.Success<void>():
        if (!mounted) {
          return;
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (Route<dynamic> route) => false,
        );

      case app_result.Error<void>():
        _showMessage('Logout failed.');
    }
  }

  void _showComingSoon() {
    _showMessage('This feature will be available soon.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<UserEntity?> _loadRemoteUser(PairingEntity pairing) {
    final String? currentUserId = sl<GetCurrentUserIdUseCase>()();

    final String remoteUid = currentUserId == pairing.requesterUid
        ? pairing.receiverUid
        : pairing.requesterUid;

    return sl<ProfileRepository>().getUser(remoteUid);
  }

  String _resolveDisplayName(UserEntity? user) {
    final String? displayName = user?.displayName?.trim();

    if (displayName != null &&
        displayName.isNotEmpty &&
        displayName != 'CAMO User') {
      return displayName;
    }

    final String email = user?.email.trim() ?? '';

    if (email.contains('@')) {
      String name = email.split('@').first;

      name = name.replaceAll('.', ' ');
      name = name.replaceAll('_', ' ');
      name = name.replaceAll('-', ' ');

      if (name.trim().isNotEmpty) {
        return name.trim();
      }
    }

    return 'CAMO User';
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
