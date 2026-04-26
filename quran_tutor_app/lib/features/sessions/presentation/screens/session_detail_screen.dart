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
      appBar: AppBar(title: const Text('Session Detail')),
      body: Center(child: Text('Session $sessionId - To be implemented')),
    );
  }
}
