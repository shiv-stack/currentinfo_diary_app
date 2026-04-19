import 'package:flutter/material.dart';
import '../../domain/entities/staff.dart';

class StaffDashboardPage extends StatelessWidget {
  final Staff staff;

  const StaffDashboardPage({super.key, required this.staff});

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
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/school-code'),
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
            color: Colors.black.withOpacity(0.04),
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
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
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
                    Icon(Icons.call_rounded, size: 14, color: Colors.grey.shade400),
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
      color: Colors.grey.shade100,
      child: Icon(Icons.person, size: 40, color: Colors.grey.shade300),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'Student Record',
        'icon': Icons.fact_check_rounded,
        'color': const Color(0xffDCF8EF),
        'iconColor': const Color(0xff00C853),
      },
      {
        'title': 'Add Student',
        'icon': Icons.person_add_rounded,
        'color': const Color(0xffFFF1E6),
        'iconColor': const Color(0xffFF6D00),
      },
      {
        'title': 'Attendance',
        'imagePath': 'assets/icons/attendance.png',
        'color': const Color(0xffE6F7FF),
      },
      {
        'title': 'Staff List',
        'icon': Icons.groups_rounded,
        'color': const Color(0xffE6EEFF),
        'iconColor': const Color(0xff2962FF),
      },
      {
        'title': 'Add Staff',
        'icon': Icons.group_add_rounded,
        'color': const Color(0xffF2E6FF),
        'iconColor': const Color(0xffAA00FF),
      },
      {
        'title': 'Search',
        'icon': Icons.search_rounded,
        'color': const Color(0xffFFE6E6),
        'iconColor': const Color(0xffD50000),
      },
      {
        'title': 'Upload Homework',
        'imagePath': 'assets/icons/homework.png',
        'color': const Color(0xffE6FFEF),
      },
      {
        'title': 'Check Homework',
        'icon': Icons.rule_rounded,
        'color': const Color(0xffFFFFE6),
        'iconColor': const Color(0xffFFD600),
      },
      {
        'title': 'Upload Marks',
        'imagePath': 'assets/icons/marks.png',
        'color': const Color(0xffE6F7FF),
      },
      {
        'title': 'Check Marks',
        'icon': Icons.assignment_turned_in_rounded,
        'color': const Color(0xffF2F2F2),
        'iconColor': const Color(0xff424242),
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
        'icon': Icons.checklist_rounded,
        'color': const Color(0xffE0F2F1),
        'iconColor': const Color(0xff00796B),
      },
      {
        'title': 'Class Circular',
        'icon': Icons.campaign_rounded,
        'color': const Color(0xffFFF3E0),
        'iconColor': const Color(0xffE65100),
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
            // Navigation will be implemented as detail pages are ready
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
                  child: item.containsKey('icon')
                      ? Icon(
                          item['icon'] as IconData,
                          size: 36,
                          color: item['iconColor'] as Color,
                        )
                      : Image.asset(
                          item['imagePath'] as String,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(height: 8),
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

