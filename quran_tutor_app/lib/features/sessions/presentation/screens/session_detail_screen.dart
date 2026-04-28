import 'package:flutter/material.dart';

class SessionDetailScreen extends StatelessWidget {

  const SessionDetailScreen({
    required this.sessionId, super.key,
    this.isTeacher = false,
  });
  final String sessionId;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(sessionId)),
      body: const Center(child: Text('SessionDetailScreen')),
    );
  }
}
