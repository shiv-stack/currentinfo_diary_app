import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../data/models/student_model.dart';
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
          title: Text(
            widget.marksExam,
            style: const TextStyle(
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "No scores available for this exam",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.details.length,
                  itemBuilder: (context, index) {
                    final detail = state.details[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail.subject ?? "Unknown Subject",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Color(0xFF1A1C1E),
                                    ),
                                  ),
                                  if (detail.grade != null &&
                                      detail.grade!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "Grade: ${detail.grade}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: detail.marksObtained ?? "0",
                                      style: const TextStyle(
                                        color: Color(0xFF166534),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " / ${detail.maxMarks ?? '0'}",
                                      style: const TextStyle(
                                        color: Color(0xFF15803D),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is MarkDetailsFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "Unable to fetch marks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                        child: Text(
                          "The server is having some trouble. Please try again in a few moments.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchMarkDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2DCE89),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text("Loading..."));
            },
          ),
        ),
      ),
    );
  }
}
