import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../injection_container.dart' as di;

class AttendancePage extends StatefulWidget {
  final StudentModel student;
  const AttendancePage({super.key, required this.student});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String _selectedMonthValue = "Complete Attendance";
  final List<String> _months = [
    "Complete Attendance",
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }



  void _fetchAttendance() async {
    final authLocal = di.sl<AuthLocalDataSource>();
    final schoolCode = await authLocal.getCachedSchoolCode();
    final session = await authLocal.getCachedSession() ?? "2025-2026";
    final creds = await authLocal.getCachedStudentCredentials(schoolCode ?? "");

    if (schoolCode != null && creds != null && mounted) {
      context.read<StudentBloc>().add(
            GetAttendance(
              schoolCode: schoolCode,
              cdiaryId: widget.student.cdiaryId ?? "",
              password: creds['password'] ?? "",
              session: session,
              month: _selectedMonthValue == "Complete Attendance" ? "" : _selectedMonthValue,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1C1E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Attendance",
            style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildMonthSelector(),
            Expanded(
              child: BlocBuilder<StudentBloc, StudentState>(
                builder: (context, state) {
                  if (state is AttendanceLoading) {
                    return const AppLoadingIndicator();
                  } else if (state is AttendanceFailure) {
                    return Center(child: Text(state.message));
                  } else if (state is AttendanceLoaded) {
                    if (state.attendance.isEmpty) {
                      return const Center(child: Text("No records found"));
                    }
                    return Column(
                      children: [
                        _buildAttendanceSummary(state.attendance),
                        Expanded(
                          child: _buildAttendanceList(state.attendance),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary(List<dynamic> attendance) {
    if (attendance.isEmpty) return const SizedBox.shrink();

    final total = attendance.length;
    final present = attendance
        .where((record) =>
            (record['attendance'] as String? ?? '').toLowerCase().contains('present'))
        .length;
    final percentage = (present / total) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: AppLoadingIndicator(
                    centered: false,
                    value: percentage / 100,
                    strokeWidth: 8,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "${percentage.toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Attendance Score",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    percentage >= 75 ? "Excellent!" : "Needs Improvement",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$present out of $total days present",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedMonthValue,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).primaryColor),
            style: const TextStyle(
              color: Color(0xFF1A1C1E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            items: _months.map((String month) {
              return DropdownMenuItem(
                value: month,
                child: Text(month),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMonthValue = value;
                });
                _fetchAttendance();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList(List<dynamic> attendance) {
    return ListView.builder(
      itemCount: attendance.length,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemBuilder: (context, index) {
        final record = attendance[index];
        final status = (record['attendance'] as String? ?? '').toLowerCase();
        final rawDate = record['date'] as String? ?? '';
        final studentName = record['name'] as String? ?? '';

        String datePart = rawDate;
        String timePart = '';

        if (rawDate.contains(' ')) {
          final parts = rawDate.split(' ');
          datePart = parts[0];
          timePart = parts[1];
        }

        Color statusColor;
        IconData statusIcon;
        String statusLabel;

        if (status.contains('present')) {
          statusColor = const Color(0xFF4CAF50);
          statusIcon = Icons.check_circle_rounded;
          statusLabel = "Present";
        } else if (status.contains('absent')) {
          statusColor = const Color(0xFFE57373);
          statusIcon = Icons.cancel_rounded;
          statusLabel = "Absent";
        } else if (status.contains('leave')) {
          statusColor = const Color(0xFFFFB74D);
          statusIcon = Icons.info_rounded;
          statusLabel = "Leave";
        } else {
          statusColor = Colors.grey;
          statusIcon = Icons.help_rounded;
          statusLabel = record['attendance'] ?? 'Unknown';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      datePart,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                    if (timePart.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        timePart,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
