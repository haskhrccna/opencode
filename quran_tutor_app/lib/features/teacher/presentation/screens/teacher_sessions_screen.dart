import 'package:flutter/material.dart';

class TeacherSessionsScreen extends StatelessWidget {
  const TeacherSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الجلسات')),
      body: const Center(child: Text('قائمة الجلسات')),
    );
  }
}
