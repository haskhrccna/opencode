import 'package:flutter/material.dart';

class TeacherManagementScreen extends StatelessWidget {
  const TeacherManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المعلمين')),
      body: const Center(child: Text('قائمة المعلمين')),
    );
  }
}
