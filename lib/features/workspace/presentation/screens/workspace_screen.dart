// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes.dart';
import '../../../admin/data/services/firebase_camo_admin_access_service.dart';
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
import '../../../pairing/presentation/screens/qr_scanner_screen.dart';
import '../../../notifications/domain/entities/camo_notification_feed.dart';
import '../../../notifications/presentation/providers/other_notifications_provider.dart';
import '../../../notifications/presentation/screens/other_notifications_panel.dart';
import '../../../dashboard/presentation/widgets/identity_qr_dialog.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/presentation/providers/my_identity_controller.dart';
import '../providers/workspace_controller.dart';
import '../providers/workspace_state.dart';
import '../widgets/camo_workspace_operation_banner.dart';
import '../widgets/camo_workspace_terminology.dart';
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
  bool _showAdminConsole = false;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  CamoWorkspaceTab _selectedTab = CamoWorkspaceTab.encoder;
  PairingEntity? _selectedPair;
  final bool _isCamouflageEnabled = false;
  bool _routePairLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAdminConsoleVisibility();
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
        onPairingHubTap: _openPairingHub,
        onHistoryTap: _openHistory,
        onSubscriptionTap: _openSubscription,
        onSecurityCenterTap: _openSecurityCenter,
        onSettingsTap: _openSettings,
        onAboutTap: _closeDrawerAndShowComingSoon,
        onLogoutTap: _logout,
        showAdminConsole: _showAdminConsole,
        onAdminConsoleTap: _openAdminConsole,
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
                  onScanQrTap: _showScannerPanel,
                  onIdentityTap: _showIdentityPanel,
                );
              },
            ),
            Expanded(
              child: ResponsiveContainer(
                child: Padding(
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
                      Expanded(
                        child: CamoWorkspaceBox(
                          title: CamoWorkspaceTerminology.title(_selectedTab),
                          expandChild: true,
                          child: _buildWorkspaceContent(canRun, workspaceState),
                        ),
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

  Widget _buildWorkspaceContent(bool canRun, WorkspaceState workspaceState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CamoWorkspaceOperationBanner(status: workspaceState.operationStatus),
        CamoSpacing.gapSm,
        CamoCamouflageSwitch(value: _isCamouflageEnabled, onChanged: null),
        if (_isCamouflageEnabled) ...[
          CamoSpacing.gapLg,
          CamoSubjectField(controller: _subjectController),
        ],
        CamoSpacing.gapSm,
        Expanded(
          child: CamoInputField(
            controller: _inputController,
            onPasteTap: _pasteInput,
            onClearTap: _clearInput,
          ),
        ),
        CamoSpacing.gapSm,
        CamoActionButton(
          label: CamoWorkspaceTerminology.action(_selectedTab),
          icon: _selectedTab == CamoWorkspaceTab.encoder
              ? CamoIcons.encode
              : CamoIcons.decode,
          onPressed: canRun ? _runWorkspaceAction : null,
          isLoading: workspaceState.isLoading,
        ),
        CamoSpacing.gapSm,
        Expanded(
          child: CamoOutputField(
            controller: _outputController,
            onCopyTap: _copyOutput,
            onShareTap: _shareOutput,
            onClearTap: _clearOutput,
          ),
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
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close identity card',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 58, 8, 8),
              child: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(myIdentityControllerProvider);
                  final controller = ref.read(
                    myIdentityControllerProvider.notifier,
                  );
                  final accepted = ref.watch(acceptedPairingsProvider);
                  final isPaired = accepted.when(
                    data: (List<PairingEntity> items) => items.isNotEmpty,
                    loading: () => false,
                    error: (_, _) => false,
                  );
                  return Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width - 16,
                      ),
                      child: CamoIdentityPanel(
                        camoId: state.camoId,
                        isVisible: state.isVisible,
                        isPaired: isPaired,
                        onVisibilityTap: controller.toggleVisibility,
                        onCopyTap: () async {
                          final copied = await controller.copyCamoId();
                          if (copied && mounted) {
                            _showMessage('CAMO ID copied.');
                          }
                        },
                        onQrTap: () {
                          if (state.camoId.trim().isEmpty) return;
                          showDialog<void>(
                            context: context,
                            builder: (_) =>
                                IdentityQrDialog(camoId: state.camoId),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.12, end: 1.0).animate(curved),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _showScannerPanel() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close scanner',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        final size = MediaQuery.sizeOf(context);
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 58, 8, 8),
              child: SizedBox(
                width: size.width < 380 ? size.width - 16 : 360,
                height: (size.height - 90).clamp(320.0, 500.0),
                child: const QrScannerScreen(compact: true),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.12, end: 1.0).animate(curved),
            alignment: Alignment.topRight,
            child: child,
          ),
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
        subject: null,
        camouflageEnabled: false,
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

  Future<void> _loadAdminConsoleVisibility() async {
    final bool allowed = await FirebaseCamoAdminAccessService()
        .hasFreshAdminAccess();

    if (!mounted) {
      return;
    }

    setState(() {
      _showAdminConsole = allowed;
    });
  }

  void _openAdminConsole() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.adminConsole);
  }

  void _openSettings() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  void _openSubscription() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.subscription);
  }

  void _openSecurityCenter() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.securityCenter);
  }

  void _openPairingHub() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.myPairings);
  }

  void _openHistory() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.history);
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
