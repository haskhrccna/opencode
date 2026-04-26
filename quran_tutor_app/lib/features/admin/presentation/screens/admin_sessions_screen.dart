import 'package:flutter/material.dart';

class AdminSessionsScreen extends StatelessWidget {
  const AdminSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جلسات النظام')),
      body: const Center(child: Text('قائمة الجلسات')),
    );
  }
}
