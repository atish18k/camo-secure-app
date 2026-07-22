import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/firebase_camo_admin_commercial_request_repository.dart';
import '../../domain/repositories/camo_admin_commercial_request_repository.dart';

class CamoAdminPendingCommercialRequestsPanel extends StatefulWidget {
  const CamoAdminPendingCommercialRequestsPanel({super.key, this.repository});

  final CamoAdminCommercialRequestRepository? repository;

  @override
  State<CamoAdminPendingCommercialRequestsPanel> createState() =>
      _CamoAdminPendingCommercialRequestsPanelState();
}

class _CamoAdminPendingCommercialRequestsPanelState
    extends State<CamoAdminPendingCommercialRequestsPanel> {
  static const List<int> _durations = <int>[1, 3, 7, 10];

  late final CamoAdminCommercialRequestRepository _repository;
  List<CamoPendingCommercialRequest> _requests =
      const <CamoPendingCommercialRequest>[];
  final Map<String, int> _selectedDuration = <String, int>{};
  final Set<String> _approving = <String>{};
  bool _loading = true;
  String? _error;

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
      final List<CamoPendingCommercialRequest> requests = await _repository
          .listPendingRequests();
      if (!mounted) {
        return;
      }
      setState(() {
        _requests = requests;
        for (final CamoPendingCommercialRequest request in requests) {
          _selectedDuration.putIfAbsent(request.requestId, () => 1);
        }
      });
    } on FirebaseFunctionsException catch (error) {
      _setError(error.message ?? 'Pending requests could not be loaded.');
    } catch (_) {
      _setError('Pending requests could not be loaded.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _setError(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _error = message);
  }

  Future<void> _approve(CamoPendingCommercialRequest request) async {
    final int duration = _selectedDuration[request.requestId] ?? 1;
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Approve Commercial Access?'),
            content: Text(
              'Approve ${request.userEmail ?? request.userId} '
              'for $duration day(s)?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Approve'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _approving.add(request.requestId));
    try {
      final CamoApprovedCommercialRequest approved = await _repository
          .approveRequest(requestId: request.requestId, durationDays: duration);
      if (!mounted) {
        return;
      }
      setState(() {
        _requests = _requests
            .where((item) => item.requestId != request.requestId)
            .toList(growable: false);
        _approving.remove(request.requestId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Access approved for ${approved.durationDays} day(s).'),
        ),
      );
    } on FirebaseFunctionsException catch (error) {
      _approvalFailed(
        request.requestId,
        error.message ?? 'Approval was denied by the server.',
      );
    } catch (_) {
      _approvalFailed(request.requestId, 'Approval failed closed.');
    }
  }

  void _approvalFailed(String requestId, String message) {
    if (!mounted) {
      return;
    }
    setState(() => _approving.remove(requestId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('pending-commercial-requests-panel'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.workspace_premium_outlined),
                    title: Text('Pending Commercial Access Requests'),
                    subtitle: Text('Choose 1, 3, 7, or 10 days and approve.'),
                  ),
                ),
                IconButton(
                  key: const Key('refresh-commercial-requests'),
                  onPressed: _loading ? null : _load,
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(
                _error!,
                key: const Key('commercial-request-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (_requests.isEmpty)
              const Text(
                'No pending commercial access requests.',
                key: Key('no-pending-commercial-requests'),
              )
            else
              ..._requests.map(
                (CamoPendingCommercialRequest request) => Card(
                  key: Key('commercial-request-${request.requestId}'),
                  margin: const EdgeInsets.only(top: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 280,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                request.userEmail ?? 'Registered CAMO user',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text('UID: ${request.userId}'),
                              Text(
                                request.requestedAt == null
                                    ? 'Requested: pending'
                                    : 'Requested: ${request.requestedAt!.toLocal()}',
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<int>(
                          key: Key('commercial-duration-${request.requestId}'),
                          value: _selectedDuration[request.requestId] ?? 1,
                          onChanged: _approving.contains(request.requestId)
                              ? null
                              : (int? value) {
                                  if (value != null) {
                                    setState(
                                      () =>
                                          _selectedDuration[request.requestId] =
                                              value,
                                    );
                                  }
                                },
                          items: _durations
                              .map(
                                (int days) => DropdownMenuItem<int>(
                                  value: days,
                                  child: Text('$days day(s)'),
                                ),
                              )
                              .toList(growable: false),
                        ),
                        FilledButton.icon(
                          key: Key('approve-commercial-${request.requestId}'),
                          onPressed: _approving.contains(request.requestId)
                              ? null
                              : () => _approve(request),
                          icon: _approving.contains(request.requestId)
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('Approve'),
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
}
