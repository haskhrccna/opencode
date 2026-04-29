import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:quran_tutor_app/core/theme/app_colors.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_state.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<ProfileBloc>().add(LoadStudentsByTeacher(user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلابي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = context.read<AuthBloc>().state.user;
              if (user != null) {
                context.read<ProfileBloc>().add(LoadStudentsByTeacher(user.id));
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = state.students ?? [];

          if (students.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: AppColors.outline),
                  SizedBox(height: 16),
                  Text('لا يوجد طلاب مسندون إليك'),
                  SizedBox(height: 8),
                  Text(
                    'سيتم إسناد الطلاب إليك من قبل الإدارة',
                    style: TextStyle(color: AppColors.outline),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _StudentCard(
                student: student,
                onTap: () => context.push('/teacher/students/${student.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, this.onTap});

  final UserProfile student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage:
                    student.hasAvatar ? NetworkImage(student.photoUrl!) : null,
                child: !student.hasAvatar
                    ? Text(
                        student.initials,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.displayNameOrEmail,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    if (student.phoneNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        student.phoneNumber!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
