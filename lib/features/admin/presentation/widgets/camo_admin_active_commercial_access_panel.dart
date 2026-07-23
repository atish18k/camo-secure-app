import 'package:flutter/material.dart';

import '../../../../core/theme/camo_spacing.dart';
import '../../data/repositories/firebase_camo_admin_commercial_request_repository.dart';
import '../../domain/repositories/camo_admin_commercial_request_repository.dart';

class CamoAdminActiveCommercialAccessPanel extends StatefulWidget {
  const CamoAdminActiveCommercialAccessPanel({super.key, this.repository});

  final CamoAdminCommercialRequestRepository? repository;

  @override
  State<CamoAdminActiveCommercialAccessPanel> createState() =>
      _CamoAdminActiveCommercialAccessPanelState();
}

class _CamoAdminActiveCommercialAccessPanelState
    extends State<CamoAdminActiveCommercialAccessPanel> {
  late final CamoAdminCommercialRequestRepository _repository;
  bool _loading = true;
  String? _error;
  String? _busyUserId;
  List<CamoActiveCommercialAccess> _access =
      const <CamoActiveCommercialAccess>[];

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? FirebaseCamoAdminCommercialRequestRepository();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<CamoActiveCommercialAccess> access = await _repository
          .listActiveAccess();
      if (!mounted) {
        return;
      }
      setState(() {
        _access = access;
        _loading = false;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Active commercial access is unavailable.';
        _loading = false;
      });
    }
  }

  Future<void> _revoke(CamoActiveCommercialAccess access) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Revoke commercial access?'),
            content: Text(
              'Access for ${access.userEmail ?? access.userId} will stop immediately.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Revoke'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _busyUserId = access.userId);

    try {
      await _repository.revokeAccess(userId: access.userId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commercial access revoked.')),
      );
      await _load();
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commercial access revoke failed.')),
      );
    } finally {
      if (mounted) {
        setState(() => _busyUserId = null);
      }
    }
  }

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
                const Expanded(
                  child: Text(
                    'Active commercial access',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh active access',
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: CamoSpacing.sm),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error case final String message)
              Column(
                children: <Widget>[
                  Text(message),
                  const SizedBox(height: CamoSpacing.sm),
                  FilledButton.tonal(
                    onPressed: _load,
                    child: const Text('Retry'),
                  ),
                ],
              )
            else if (_access.isEmpty)
              const Text('No active commercial access.')
            else
              ..._access.map(
                (CamoActiveCommercialAccess access) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(access.userEmail ?? access.userId),
                  subtitle: Text(
                    '${access.planId} • expires ${access.expiresAt.toLocal()}',
                  ),
                  trailing: FilledButton.tonalIcon(
                    onPressed: _busyUserId == access.userId
                        ? null
                        : () => _revoke(access),
                    icon: const Icon(Icons.block_rounded),
                    label: const Text('Revoke'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
