import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/staff.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../routes/app_routes.dart';
import './staff_upload_page.dart';
import './student_record_page.dart';
import './add_student_page.dart';
import '../bloc/user_detail_cubit.dart';
import '../../../../injection_container.dart' as di;

class StaffDashboardPage extends StatelessWidget {
  final Staff staff;

  const StaffDashboardPage({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess || state is NavigateToSchoolCode) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.schoolCode,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Staff Panel",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1C1E),
                        letterSpacing: -0.8,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          context.read<AuthBloc>().add(StaffLogout()),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Staff Card
                _buildStaffCard(context),

                const SizedBox(height: 32),

                // Grid Section Title
                const Text(
                  "Management Features",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1C1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Action Grid
                _buildActionGrid(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: staff.staffImage != null && staff.staffImage!.isNotEmpty
                  ? Image.network(
                      staff.staffImage!,
                      width: 90,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
          ),
          const SizedBox(width: 20),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    staff.designation?.toUpperCase() ?? "STAFF MEMBER",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  staff.name ?? 'Staff Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1C1E),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.call_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      staff.contactNumber ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 90,
      height: 110,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        'assets/icons/profile.png',
        fit: BoxFit.contain,
        opacity: const AlwaysStoppedAnimation(0.5),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'User Record',
        'imagePath': 'assets/icons/student_record.png',
        'color': const Color(0xffDCF8EF),
      },
      {
        'title': 'Add User',
        'imagePath': 'assets/icons/add_student.png',
        'color': const Color(0xffFFF1E6),
      },
      {
        'title': 'Attendance',
        'imagePath': 'assets/icons/attendance.png',
        'color': const Color(0xffE6F7FF),
      },
      // {
      //   'title': 'Staff List',
      //   'imagePath': 'assets/icons/staff_list.png',
      //   'color': const Color(0xffE6EEFF),
      // },
      // {
      //   'title': 'Add Staff',
      //   'imagePath': 'assets/icons/add_staff.png',
      //   'color': const Color(0xffF2E6FF),
      // },
      {
        'title': 'Search',
        'imagePath': 'assets/icons/search.png',
        'color': const Color(0xffFFE6E6),
      },
      {
        'title': 'Upload Homework',
        'imagePath': 'assets/icons/homework.png',
        'color': const Color(0xffE6FFEF),
      },
      {
        'title': 'Check Homework',
        'imagePath': 'assets/icons/check_homework.png',
        'color': const Color(0xffFFFFE6),
      },
      {
        'title': 'Upload Marks',
        'imagePath': 'assets/icons/marks.png',
        'color': const Color(0xffE6F7FF),
      },
      {
        'title': 'Check Marks',
        'imagePath': 'assets/icons/check_marks.png',
        'color': const Color(0xffF2F2F2),
      },
      {
        'title': 'Upload Notice',
        'imagePath': 'assets/icons/class_notice.png',
        'color': const Color(0xffFFE6F7),
      },
      {
        'title': 'Fees',
        'imagePath': 'assets/icons/fees.png',
        'color': const Color(0xffFFF9E6),
      },
      {
        'title': 'Leave Management',
        'imagePath': 'assets/icons/apply_leave.png',
        'color': const Color(0xffF3E5F5),
      },
      {
        'title': 'Task to Do',
        'imagePath': 'assets/icons/task_to_do.png',
        'color': const Color(0xffE0F2F1),
      },
      {
        'title': 'Class Circular',
        'imagePath': 'assets/icons/class_circular.png',
        'color': const Color(0xffFFF3E0),
      },
      {
        'title': 'Holiday Homework',
        'imagePath': 'assets/icons/homework.png',
        'color': const Color(0xffE1F5FE),
      },
      {
        'title': 'Datesheet',
        'imagePath': 'assets/icons/datesheet.png',
        'color': const Color(0xffFCE4EC),
      },
      {
        'title': 'Timetable',
        'imagePath': 'assets/icons/timetable_new.png',
        'color': const Color(0xffE8EAF6),
      },
      {
        'title': 'Syllabus',
        'imagePath': 'assets/icons/syllabus.png',
        'color': const Color(0xffF3E5F5),
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      padding: EdgeInsets.zero,
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return InkWell(
          onTap: () {
            final uploadFeatures = [
              'Upload Homework',
              'Upload Notice',
              'Class Circular',
              'Holiday Homework',
              'Datesheet',
              'Timetable',
              'Syllabus',
            ];

            if (uploadFeatures.contains(item['title'])) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaffUploadPage(
                    featureTitle: item['title'] as String,
                    staff: staff,
                  ),
                ),
              );
            } else if (item['title'] == 'User Record') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentRecordPage(staff: staff),
                ),
              );
            } else if (item['title'] == 'Add User') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => di.sl<UserDetailCubit>(),
                    child: AddStudentPage(staff: staff),
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    item['imagePath'] as String,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1C1E),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
