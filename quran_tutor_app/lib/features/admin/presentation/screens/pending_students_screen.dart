import 'package:flutter/material.dart';

class PendingStudentsScreen extends StatelessWidget {
  const PendingStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطلاب المعلقون')),
      body: const Center(child: Text('قائمة الطلاب المعلقين')),
    );
  }
}
