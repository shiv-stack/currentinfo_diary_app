import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../data/models/student_model.dart';
import '../../data/models/mark_detail_model.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../injection_container.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/utils/app_toast.dart';
import 'package:flutter/services.dart';

class MarkDetailsPage extends StatefulWidget {
  final StudentModel student;
  final String marksClass;
  final String marksYear;
  final String marksExam;

  const MarkDetailsPage({
    super.key,
    required this.student,
    required this.marksClass,
    required this.marksYear,
    required this.marksExam,
  });

  @override
  State<MarkDetailsPage> createState() => _MarkDetailsPageState();
}

class _MarkDetailsPageState extends State<MarkDetailsPage> {
  @override
  void initState() {
    super.initState();
    _fetchMarkDetails();
  }

  void _fetchMarkDetails() async {
    final authLocal = sl<AuthLocalDataSource>();
    final code = await authLocal.getCachedSchoolCode();
    final creds = await authLocal.getActiveStudentCredentials();
    if (code != null && creds != null) {
      if (!mounted) return;
      context.read<StudentBloc>().add(
        GetMarkDetails(
          schoolCode: code,
          studentId: widget.student.cdiaryId ?? '',
          password: creds['password'] ?? '',
          session: widget.student.session ?? '',
          marksClass: widget.marksClass,
          marksYear: widget.marksYear,
          marksExam: widget.marksExam,
        ),
      );
    }
  }

  double _calculatePercentage(List<MarkDetailModel> details) {
    double totalObtained = 0;
    double totalMax = 0;
    bool hasData = false;

    for (var detail in details) {
      if (detail.marksObtained != null && detail.maxMarks != null) {
        final obtained = double.tryParse(detail.marksObtained!);
        final max = double.tryParse(detail.maxMarks!);
        if (obtained != null && max != null && max > 0) {
          totalObtained += obtained;
          totalMax += max;
          hasData = true;
        }
      }
    }
    return hasData ? (totalObtained / totalMax) * 100 : 0;
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1C1E),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "REPORT CARD",
            style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocListener<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is MarkDetailsFailure) {
              AppToast.show(context, state.message);
            }
          },
          child: BlocBuilder<StudentBloc, StudentState>(
            builder: (context, state) {
              if (state is MarkDetailsLoading) {
                return const Center(child: AppLoadingIndicator());
              } else if (state is MarkDetailsLoaded) {
                if (state.details.isEmpty) {
                  return _buildEmptyState();
                }

                final percentage = _calculatePercentage(state.details);

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeaderCard(percentage, state.details),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _buildMainReportCard(state.details),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              } else if (state is MarkDetailsFailure) {
                return _buildErrorState();
              }
              return const Center(child: Text("Loading..."));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainReportCard(List<MarkDetailModel> details) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "SUBJECT",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "GRADE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "SCORE",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ...details.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = entry.value;
            final isLast = index == details.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          detail.subject ?? "Unknown",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          (detail.grade != null && detail.grade!.isNotEmpty)
                              ? detail.grade!.toUpperCase()
                              : "—",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: (detail.marksObtained != null)
                            ? Text(
                                "${detail.marksObtained} / ${detail.maxMarks ?? '-'}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: primaryColor,
                                ),
                              )
                            : const Text(
                                "—",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(double percentage, List<MarkDetailModel> details) {
    final primaryColor = Theme.of(context).primaryColor;
    final rollNo = details.isNotEmpty ? details.first.rollNo : null;
    final attendance = details.isNotEmpty ? details.first.attendance : null;
    final totalAttendance = details.isNotEmpty
        ? details.first.totalAttendance
        : null;
    final enrollmentNumber = details.isNotEmpty
        ? details.first.enrollmentNumber
        : null;

    String attendanceLabel = "Attd: ";
    if (attendance != null && totalAttendance != null) {
      attendanceLabel += "$attendance / $totalAttendance";
    } else if (attendance != null) {
      attendanceLabel += attendance;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.student.name ?? "Student",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Class: ${widget.marksClass} | ${widget.marksExam}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (percentage > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
          if (rollNo != null ||
              attendance != null ||
              enrollmentNumber != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (enrollmentNumber != null)
                  _buildHeaderInfoChip(
                    Icons.assignment_ind_rounded,
                    "Enroll: $enrollmentNumber",
                  ),
                if (rollNo != null)
                  _buildHeaderInfoChip(
                    Icons.numbers_rounded,
                    "Roll No : $rollNo",
                  ),
                if (attendance != null)
                  _buildHeaderInfoChip(
                    Icons.calendar_today_rounded,
                    attendanceLabel,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            "No Results Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back after the school releases grades.",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          const Text(
            "Connection Error",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Text(
              "We couldn't reach the school server. Please check your internet connection.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchMarkDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DCE89),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: const Text("TRY AGAIN"),
          ),
        ],
      ),
    );
  }
}
