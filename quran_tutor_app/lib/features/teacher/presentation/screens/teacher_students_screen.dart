import 'package:flutter/material.dart';

class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلابي')),
      body: const Center(child: Text('قائمة الطلاب')),
    );
  }
}
