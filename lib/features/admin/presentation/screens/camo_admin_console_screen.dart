import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../widgets/camo_admin_pending_commercial_requests_panel.dart';

import '../widgets/camo_admin_active_commercial_access_panel.dart';
import '../../../../app/routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/result.dart' as app_result;
import '../../../../core/theme/camo_colors.dart';
import '../../../../core/theme/camo_spacing.dart';
import '../../../../core/theme/camo_typography.dart';
import '../../../../shared/layouts/responsive_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/repositories/firebase_camo_admin_device_repository.dart';
import '../../domain/entities/camo_admin_device.dart';
import '../../domain/entities/camo_admin_device_request.dart';
import '../../domain/repositories/camo_admin_device_request_repository.dart';

class CamoAdminConsoleScreen extends StatefulWidget {
  final Widget? pendingCommercialRequestsPanel;

  final Widget? activeCommercialAccessPanel;
  const CamoAdminConsoleScreen({
    this.pendingCommercialRequestsPanel,
    this.activeCommercialAccessPanel,
    super.key,
    this.deviceRequestRepository,
  });

  final CamoAdminDeviceRequestRepository? deviceRequestRepository;

  @override
  State<CamoAdminConsoleScreen> createState() => _CamoAdminConsoleScreenState();
}

class _CamoAdminConsoleScreenState extends State<CamoAdminConsoleScreen> {
  late final CamoAdminDeviceRequestRepository _repository;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  String? _busyRequestId;
  List<CamoAdminDeviceRequest> _requests = const <CamoAdminDeviceRequest>[];
  _AdminRequestFilter _filter = _AdminRequestFilter.all;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.deviceRequestRepository ?? FirebaseCamoAdminDeviceRepository();
    _searchController.addListener(_refreshVisibleState);
    _loadRequests();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshVisibleState)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<CamoAdminDeviceRequest> requests = await _repository
          .fetchPendingRequests();

      if (!mounted) {
        return;
      }

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Callable failed: ${error.code}'
            '${error.message == null ? '' : ' - ${error.message}'}';
        _isLoading = false;
      });
    } on Object catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to load live pending device requests.';
        _isLoading = false;
      });
    }
  }

  void _refreshVisibleState() {
    if (mounted) {
      setState(() {});
    }
  }

  List<CamoAdminDeviceRequest> get _visibleRequests {
    final String query = _searchController.text.trim().toLowerCase();

    return _requests
        .where((CamoAdminDeviceRequest request) {
          final bool filterMatches = switch (_filter) {
            _AdminRequestFilter.all => true,
            _AdminRequestFilter.pending =>
              request.status == CamoAdminDeviceRequestStatus.pending,
          };

          if (!filterMatches) {
            return false;
          }

          if (query.isEmpty) {
            return true;
          }

          return request.userEmail.toLowerCase().contains(query) ||
              request.userId.toLowerCase().contains(query) ||
              request.deviceId.toLowerCase().contains(query) ||
              request.deviceLabel.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  Future<String?> _reasonDialog(String title) async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 200,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final String value = controller.text.trim();
              if (value.length >= 3) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _runAction(
    CamoAdminDeviceRequest request,
    Future<void> Function() action,
    String successMessage,
  ) async {
    setState(() => _busyRequestId = request.requestId);

    try {
      await action();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      await _loadRequests();
    } on Object {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin action failed closed.')),
      );
    } finally {
      if (mounted) {
        setState(() => _busyRequestId = null);
      }
    }
  }

  Future<void> _approve(CamoAdminDeviceRequest request) => _runAction(
    request,
    () => _repository.approveRequest(
      userId: request.userId,
      requestId: request.requestId,
    ),
    'Device approved.',
  );

  Future<void> _reject(CamoAdminDeviceRequest request) async {
    final String? reason = await _reasonDialog('Reject device request');

    if (reason == null) {
      return;
    }

    await _runAction(
      request,
      () => _repository.rejectRequest(
        userId: request.userId,
        requestId: request.requestId,
        reason: reason,
      ),
      'Device request rejected.',
    );
  }

  Future<void> _showDevices(CamoAdminDeviceRequest request) async {
    List<CamoAdminDevice> devices;

    try {
      devices = await _repository.fetchDevices(request.userId);
    } on Object {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load active devices.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Active Devices ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â ${request.userEmail}'),
        content: SizedBox(
          width: 600,
          child: devices.isEmpty
              ? const Text('No active or revoked devices found.')
              : ListView(
                  shrinkWrap: true,
                  children: devices
                      .map(
                        (CamoAdminDevice item) => ListTile(
                          leading: Icon(
                            item.isApproved
                                ? Icons.verified_user_rounded
                                : Icons.block_rounded,
                          ),
                          title: Text(item.deviceId),
                          subtitle: Text(
                            '${item.platform} ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ${item.status}',
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _replace(CamoAdminDeviceRequest request) async {
    List<CamoAdminDevice> devices;

    try {
      devices = await _repository.fetchDevices(request.userId);
    } on Object {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load active devices.')),
      );
      return;
    }

    final List<CamoAdminDevice> activeDevices = devices
        .where((CamoAdminDevice device) => device.isApproved)
        .toList(growable: false);

    if (!mounted) {
      return;
    }

    if (activeDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active device is available to replace.'),
        ),
      );
      return;
    }

    String selectedDeviceId = activeDevices.first.deviceId;
    final String? previousDeviceId = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
          title: const Text('Select old device to revoke'),
          content: DropdownButtonFormField<String>(
            initialValue: selectedDeviceId,
            items: activeDevices
                .map(
                  (CamoAdminDevice device) => DropdownMenuItem<String>(
                    value: device.deviceId,
                    child: Text(
                      '${device.platform} ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â ${device.deviceId}',
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (String? value) {
              if (value != null) {
                setDialogState(() => selectedDeviceId = value);
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, selectedDeviceId),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );

    if (previousDeviceId == null || !mounted) {
      return;
    }

    final String? reason = await _reasonDialog('Device replacement reason');

    if (reason == null) {
      return;
    }

    await _runAction(
      request,
      () => _repository.replaceDevice(
        userId: request.userId,
        requestId: request.requestId,
        previousDeviceId: previousDeviceId,
        reason: reason,
      ),
      'New device approved and old device revoked.',
    );
  }

  Future<void> _logout() async {
    final app_result.Result<void> result = await sl<AuthRepository>().signOut();

    if (!mounted) {
      return;
    }

    switch (result) {
      case app_result.Success<void>():
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (Route<dynamic> route) => false,
        );
      case app_result.Error<void>():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logout failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<CamoAdminDeviceRequest> visibleRequests = _visibleRequests;
    final int pendingCount = _requests
        .where(
          (CamoAdminDeviceRequest request) =>
              request.status == CamoAdminDeviceRequestStatus.pending,
        )
        .length;

    return Scaffold(
      backgroundColor: CamoColors.background,
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadRequests,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: ListView(
            padding: CamoSpacing.screen,
            children: <Widget>[
              // MP-030 owns device-administration operations only.
              // MP-030C remains separately bounded and owns commercial access.
              widget.pendingCommercialRequestsPanel ??
                  const CamoAdminPendingCommercialRequestsPanel(),
              const SizedBox(height: CamoSpacing.md),
              widget.activeCommercialAccessPanel ??
                  const CamoAdminActiveCommercialAccessPanel(),
              const _BoundaryBanner(),
              const SizedBox(height: CamoSpacing.lg),
              _StatisticsGrid(
                pendingCount: pendingCount,
                visibleCount: visibleRequests.length,
                totalCount: _requests.length,
              ),
              const SizedBox(height: CamoSpacing.lg),
              _SearchAndFilterBar(
                controller: _searchController,
                filter: _filter,
                onFilterChanged: (_AdminRequestFilter value) {
                  setState(() => _filter = value);
                },
                onRefresh: _isLoading ? null : _loadRequests,
              ),
              const SizedBox(height: CamoSpacing.md),
              _buildRequestContent(visibleRequests),
              const SizedBox(height: CamoSpacing.lg),
              const _DeferredModulesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestContent(List<CamoAdminDeviceRequest> visibleRequests) {
    if (_isLoading) {
      return const _AdminLoadingState();
    }

    if (_errorMessage case final String message) {
      return _AdminErrorState(message: message, onRetry: _loadRequests);
    }

    if (_requests.isEmpty) {
      return const _AdminEmptyState(
        title: 'No pending device requests',
        message: 'There are no live requests awaiting action.',
      );
    }

    if (visibleRequests.isEmpty) {
      return const _AdminEmptyState(
        title: 'No matching requests',
        message: 'Change the search text or selected filter.',
      );
    }

    return Column(
      children: visibleRequests
          .map(
            (CamoAdminDeviceRequest request) => _PendingDeviceRequestCard(
              request: request,
              isBusy: _busyRequestId == request.requestId,
              onApprove: () => _approve(request),
              onReject: () => _reject(request),
              onShowDevices: () => _showDevices(request),
              onReplace: () => _replace(request),
            ),
          )
          .toList(growable: false),
    );
  }
}

enum _AdminRequestFilter { all, pending }

class _BoundaryBanner extends StatelessWidget {
  const _BoundaryBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CamoSpacing.md),
      decoration: BoxDecoration(
        color: CamoColors.surface,
        border: Border.all(color: CamoColors.primary),
        borderRadius: BorderRadius.circular(CamoSpacing.md),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.admin_panel_settings_rounded, color: CamoColors.primary),
          SizedBox(width: CamoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Authorized admin session',
                  style: CamoTypography.bodyStrong,
                ),
                SizedBox(height: CamoSpacing.xs),
                Text(
                  'Live server-authorized device administration. '
                  'Privileged writes are performed only by audited callables.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid({
    required this.pendingCount,
    required this.visibleCount,
    required this.totalCount,
  });

  final int pendingCount;
  final int visibleCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 720;
        final int columns = compact ? 1 : 3;
        final double spacing = CamoSpacing.md;
        final double itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        final List<Widget> cards = <Widget>[
          _StatisticCard(
            label: 'Pending requests',
            value: '$pendingCount',
            icon: Icons.pending_actions_rounded,
          ),
          _StatisticCard(
            label: 'Visible results',
            value: '$visibleCount',
            icon: Icons.filter_alt_rounded,
          ),
          _StatisticCard(
            label: 'Loaded records',
            value: '$totalCount',
            icon: Icons.devices_other_rounded,
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((Widget card) => SizedBox(width: itemWidth, child: card))
              .toList(growable: false),
        );
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CamoSpacing.md),
        child: Row(
          children: <Widget>[
            Icon(icon, color: CamoColors.primary),
            const SizedBox(width: CamoSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(value, style: CamoTypography.appTitle),
                  const SizedBox(height: CamoSpacing.xs),
                  Text(label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.controller,
    required this.filter,
    required this.onFilterChanged,
    required this.onRefresh,
  });

  final TextEditingController controller;
  final _AdminRequestFilter filter;
  final ValueChanged<_AdminRequestFilter> onFilterChanged;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Search requests',
            hintText: 'Email, user ID, device ID or device name',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: controller.clear,
                    icon: const Icon(Icons.clear_rounded),
                  ),
          ),
        ),
        const SizedBox(height: CamoSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: SegmentedButton<_AdminRequestFilter>(
                segments: const <ButtonSegment<_AdminRequestFilter>>[
                  ButtonSegment<_AdminRequestFilter>(
                    value: _AdminRequestFilter.all,
                    label: Text('All'),
                    icon: Icon(Icons.list_alt_rounded),
                  ),
                  ButtonSegment<_AdminRequestFilter>(
                    value: _AdminRequestFilter.pending,
                    label: Text('Pending'),
                    icon: Icon(Icons.pending_actions_rounded),
                  ),
                ],
                selected: <_AdminRequestFilter>{filter},
                onSelectionChanged: (Set<_AdminRequestFilter> selection) {
                  onFilterChanged(selection.first);
                },
              ),
            ),
            const SizedBox(width: CamoSpacing.sm),
            IconButton.filledTonal(
              tooltip: 'Refresh requests',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminLoadingState extends StatelessWidget {
  const _AdminLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(CamoSpacing.xl),
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: CamoSpacing.md),
            Text('Loading pending device requestsÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦'),
          ],
        ),
      ),
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  const _AdminErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CamoSpacing.lg),
        child: Column(
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, color: CamoColors.error),
            const SizedBox(height: CamoSpacing.sm),
            Text('Admin data unavailable', style: CamoTypography.bodyStrong),
            const SizedBox(height: CamoSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: CamoSpacing.md),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  const _AdminEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CamoSpacing.xl),
        child: Column(
          children: <Widget>[
            const Icon(Icons.inbox_outlined, color: CamoColors.primary),
            const SizedBox(height: CamoSpacing.sm),
            Text(title, style: CamoTypography.bodyStrong),
            const SizedBox(height: CamoSpacing.xs),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PendingDeviceRequestCard extends StatelessWidget {
  const _PendingDeviceRequestCard({
    required this.request,
    required this.isBusy,
    required this.onApprove,
    required this.onReject,
    required this.onShowDevices,
    required this.onReplace,
  });

  final CamoAdminDeviceRequest request;
  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onShowDevices;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CamoSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.devices_other_rounded,
                  color: CamoColors.primary,
                ),
                const SizedBox(width: CamoSpacing.sm),
                Expanded(
                  child: Text(
                    request.deviceLabel,
                    style: CamoTypography.bodyStrong,
                  ),
                ),
                const Chip(label: Text('Pending')),
              ],
            ),
            const SizedBox(height: CamoSpacing.sm),
            Text('User: ${request.userEmail}'),
            Text('User ID: ${request.userId}'),
            Text('Device ID: ${request.deviceId}'),
            Text('Platform: ${request.platform}'),
            Text('Requested: ${request.requestedAt.toLocal()}'),
            const SizedBox(height: CamoSpacing.md),
            Wrap(
              spacing: CamoSpacing.sm,
              runSpacing: CamoSpacing.sm,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: isBusy ? null : onApprove,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Approve'),
                ),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Reject'),
                ),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onShowDevices,
                  icon: const Icon(Icons.devices_rounded),
                  label: const Text('Active Devices'),
                ),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onReplace,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Device Replacement'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeferredModulesSection extends StatelessWidget {
  const _DeferredModulesSection();

  @override
  Widget build(BuildContext context) {
    const List<
      ({IconData icon, String title, String description, String status})
    >
    modules = <({IconData icon, String title, String description, String status})>[
      (
        icon: Icons.phonelink_setup_rounded,
        title: 'Device Replacement',
        description:
            'Available from each pending request through the audited server-authorized replacement workflow.',
        status: 'Request required',
      ),
      (
        icon: Icons.phonelink_erase_rounded,
        title: 'Active Devices',
        description:
            'Available from each pending request through the trusted live device-read workflow.',
        status: 'Request required',
      ),

      (
        icon: Icons.receipt_long_rounded,
        title: 'Audit History',
        description:
            'Immutable server-generated audit history remains deferred.',
        status: 'Server required',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Deferred secure modules', style: CamoTypography.appTitle),
        const SizedBox(height: CamoSpacing.sm),
        ...modules.map(
          (
            ({String description, IconData icon, String status, String title})
            module,
          ) => Padding(
            padding: const EdgeInsets.only(bottom: CamoSpacing.sm),
            child: Card(
              child: ListTile(
                leading: Icon(module.icon, color: CamoColors.primary),
                title: Text(module.title),
                subtitle: Text(module.description),
                trailing: Chip(label: Text(module.status)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
