import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_tutor_app/core/theme/app_colors.dart';
import 'package:quran_tutor_app/features/profile/domain/entities/user_profile.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_state.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({required this.studentId, super.key});
  final String studentId;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileById(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطالب')),
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
          final student = state.profile;
          if (student == null) {
            return const Center(child: Text('الطالب غير موجود'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: student.hasAvatar
                        ? NetworkImage(student.photoUrl!)
                        : null,
                    child: !student.hasAvatar
                        ? Text(
                            student.initials,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                    child: Text(student.displayNameOrEmail,
                        style: Theme.of(context).textTheme.headlineMedium)),
                if (student.email != null) _detailRow('البريد', student.email!),
                if (student.phoneNumber != null)
                  _detailRow('الهاتف', student.phoneNumber!),
                if (student.arabicName != null &&
                    student.arabicName != student.displayNameOrEmail)
                  _detailRow('العربية', student.arabicName!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(
              child:
                  Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
