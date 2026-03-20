import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:current_diary_app/core/utils/app_toast.dart';
import 'package:current_diary_app/routes/app_routes.dart';
import '../../data/models/student_model.dart';

class StudentDashboardPage extends StatelessWidget {
  final StudentModel student;

  const StudentDashboardPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Premium Greeting Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Student Pannel",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1C1E),
                      letterSpacing: -0.8,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/school-code',
                      (route) => false,
                    ),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Modern Student Info Card
              _buildModernStudentCard(context),

              const SizedBox(height: 28),

              // Feature Banner
              _buildPremiumBanner(context),

              const SizedBox(height: 32),

              // Grid Section Title
              Text(
                "Quick Services",
                style: const TextStyle(
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
    );
  }

  Widget _buildModernStudentCard(BuildContext context) {
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
      child: Column(
        children: [
          Row(
            children: [
              // Large Profile Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    student.studentImage ?? '',
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 100,
                      height: 120,
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Student Details
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
                        "CLASS ${student.className?.split(' ').last ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student.name ?? 'Full Name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1C1E),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      context,
                      Icons.cake_rounded,
                      student.dob ?? 'N/A',
                    ),
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      context,
                      Icons.call_rounded,
                      student.contactNumber ?? 'N/A',
                      onTap: () async {
                        if (student.contactNumber != null &&
                            student.contactNumber!.isNotEmpty) {
                          final uri = Uri.parse("tel:${student.contactNumber}");
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: onTap != null
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              decoration: onTap != null ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Internal decorative blob
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Floating Quote Icon (Top Right)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.format_quote_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "THOUGHT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    student.thoughtTitle ?? "Stay Inspired",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    student.thoughtMessage ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      {
        'title': 'CLASS NOTICE',
        'imagePath': 'assets/icons/class_notice.png',
        'color': const Color(0xffDCF8EF),
      },
      {
        'title': 'ATTENDANCE',
        'imagePath': 'assets/icons/attendance.png',
        'color': const Color(0xffFFF1E6),
      },
      {
        'title': 'MESSAGE',
        'imagePath': 'assets/icons/message.png',
        'color': const Color(0xffE6EEFF),
      },
      {
        'title': 'HOMEWORK',
        'imagePath': 'assets/icons/homework.png',
        'color': const Color(0xffF2E6FF),
      },
      {
        'title': 'TRACK BUS',
        'imagePath': 'assets/icons/track_bus.png',
        'color': const Color(0xffFFE6E6),
      },
      {
        'title': 'MARKS',
        'imagePath': 'assets/icons/marks.png',
        'color': const Color(0xffE6FFEF),
      },
      {
        'title': 'APPLY LEAVE',
        'imagePath': 'assets/icons/apply_leave.png',
        'color': const Color(0xffFFFFE6),
      },
      {
        'title': 'TIMETABLE IMAGE',
        'imagePath': 'assets/icons/timetable.png',
        'color': const Color(0xffF7F7F7),
      },
      {
        'title': 'FEES',
        'imagePath': 'assets/icons/fees.png',
        'color': const Color(0xffE6F7FF),
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
            if (item['title'] == 'CLASS NOTICE') {
              Navigator.pushNamed(
                context,
                AppRoutes.classNotice,
                arguments: student,
              );
            } else if (item['title'] == 'ATTENDANCE') {
              Navigator.pushNamed(
                context,
                AppRoutes.attendance,
                arguments: student,
              );
            } else {
              AppToast.show(context, "${item['title']} is Coming Soon");
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
                  padding: const EdgeInsets.all(16),
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
