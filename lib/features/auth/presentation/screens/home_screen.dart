import 'package:flutter/material.dart';

import '../../../../app/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CAMO'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 72,
              ),
              const SizedBox(height: 24),
              const Text(
                'Authentication Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.pairRequest,
                  );
                },
                icon: const Icon(Icons.link),
                label: const Text('Send Pair Request'),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.incomingPairRequests,
                  );
                },
                icon: const Icon(Icons.inbox_outlined),
                label: const Text('Incoming Requests'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}