import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh user status every 30 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => context.read<AuthBloc>().add(const RefreshUserRequested()),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'طلبك قيد المراجعة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('سيتم إشعارك عند الموافقة على طلبك'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(const SignOutRequested());
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}
