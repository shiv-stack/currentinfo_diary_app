import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/student_model.dart';

class StudentDashboardPage extends StatelessWidget {
  final StudentModel student;

  const StudentDashboardPage({super.key, required this.student});

  void _showFullWidthToast(BuildContext context, String message, Color color) {
    FToast fToast = FToast();
    fToast.init(context);
    
    final bool isError = color == AppColors.error;

    Widget toast = Container(
      width: MediaQuery.of(context).size.width - 48,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    fToast.removeCustomToast();
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          'Student Panel',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/school-code',
                  (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Thought of the day
                      if (student.thoughtTitle != null &&
                          student.thoughtMessage != null)
                        _buildThoughtCard(),

                      const SizedBox(height: 16),

                      // Student Profile Info
                      _buildStudentInfo(),

                      const SizedBox(height: 24),

                      // Action Grid
                      _buildActionGrid(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThoughtCard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.push_pin,
                size: 16,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              student.thoughtTitle ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            student.thoughtMessage ?? '',
            textAlign: TextAlign.justify,
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentInfo() {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amberAccent.shade400,
              ),
            ),
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  student.studentImage ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, err, st) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name ?? 'Unknown Student',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                student.className ?? '',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(student.dob ?? '', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 2),
              Text(
                student.contactNumber ?? '',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      {'title': 'CLASS NOTICE', 'imagePath': 'assets/icons/class_notice.png'},
      {'title': 'ATTENDANCE', 'imagePath': 'assets/icons/attendance.png'},
      {'title': 'MESSAGE', 'imagePath': 'assets/icons/message.png'},
      {'title': 'HOMEWORK', 'imagePath': 'assets/icons/homework.png'},
      {'title': 'TRACK BUS', 'imagePath': 'assets/icons/track_bus.png'},
      {'title': 'MARKS', 'imagePath': 'assets/icons/marks.png'},
      {'title': 'APPLY LEAVE', 'imagePath': 'assets/icons/apply_leave.png'},
      {'title': 'TIMETABLE IMAGE', 'imagePath': 'assets/icons/timetable.png'},
      {'title': 'FEES', 'imagePath': 'assets/icons/fees.png'},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        return InkWell(
          onTap: () {
            _showFullWidthToast(
              context,
              "${item['title']} is Coming Soon",
              Theme.of(context).primaryColor,
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        item['imagePath'] as String,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
