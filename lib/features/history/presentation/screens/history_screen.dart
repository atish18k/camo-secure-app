import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'CAMO'),
              Tab(text: 'UNCAMO'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _HistoryMetadataView(
              key: ValueKey<String>('camo-history-tab'),
              title: 'CAMO history',
              description:
                  'Secure CAMO metadata will appear after the history provider is connected.',
              fields: ['Recipient', 'Created', 'Expiry counter', 'Status'],
              actions: ['Revoke', 'Change expiry', 'Delete metadata'],
            ),
            _HistoryMetadataView(
              key: ValueKey<String>('uncamo-history-tab'),
              title: 'UNCAMO history',
              description:
                  'Secure UNCAMO metadata will appear after the history provider is connected.',
              fields: ['Sender', 'Received', 'Expiry counter', 'Status'],
              actions: ['Delete metadata'],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMetadataView extends StatelessWidget {
  const _HistoryMetadataView({
    super.key,
    required this.title,
    required this.description,
    required this.fields,
    required this.actions,
  });

  final String title;
  final String description;
  final List<String> fields;
  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(Icons.history_rounded, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: fields.map((field) => Chip(label: Text(field))).toList(),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: actions
              .map(
                (action) =>
                    OutlinedButton(onPressed: null, child: Text(action)),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Message content is never stored in History.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
