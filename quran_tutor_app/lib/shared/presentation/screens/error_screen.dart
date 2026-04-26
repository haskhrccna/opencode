// lib/features/sessions/presentation/screens/session_detail_screen.dart
import 'package:flutter/material.dart';

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  final bool isTeacher;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    this.isTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(sessionId)),
      body: const Center(child: Text('SessionDetailScreen')),
    );
  }
}