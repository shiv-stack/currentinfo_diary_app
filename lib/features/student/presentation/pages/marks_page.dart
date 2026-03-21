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
import 'mark_details_page.dart';

class MarksPage extends StatefulWidget {
  final StudentModel student;

  const MarksPage({super.key, required this.student});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  late String _selectedSession;
  late List<String> _sessions;

  @override
  void initState() {
    super.initState();
    _selectedSession = widget.student.session ?? "2025-2026";
    _generateSessions();
    _fetchExams();
  }

  void _generateSessions() {
    final now = DateTime.now();
    int year = now.year;
    // Academic sessions usually start in April
    if (now.month < 4) year--;

    _sessions = [];
    for (int i = 0; i < 5; i++) {
      int start = year - i;
      int end = start + 1;
      _sessions.add("$start-$end");
    }

    // Ensure initial session is present
    if (!_sessions.contains(_selectedSession)) {
      _sessions.insert(0, _selectedSession);
    }
  }

  void _fetchExams() async {
    final authLocal = sl<AuthLocalDataSource>();
    final code = await authLocal.getCachedSchoolCode();
    final creds = await authLocal.getActiveStudentCredentials();
    if (code != null && creds != null) {
      if (!mounted) return;
      context.read<StudentBloc>().add(
            GetExams(
              schoolCode: code,
              studentId: widget.student.cdiaryId ?? '',
              password: creds['password'] ?? '',
              session: _selectedSession,
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1C1E),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "EXAM MARKS",
            style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildSessionSelector(),
            Expanded(
              child: BlocListener<StudentBloc, StudentState>(
                listener: (context, state) {
                  if (state is ExamsFailure) {
                    AppToast.show(context, state.message);
                  }
                },
                child: BlocBuilder<StudentBloc, StudentState>(
                  builder: (context, state) {
                    if (state is ExamsLoading) {
                      return const Center(child: AppLoadingIndicator());
                    } else if (state is ExamsLoaded) {
                      if (state.exams.isEmpty) {
                        return const Center(
                          child: Text(
                            "No exams found",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => _fetchExams(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.exams.length,
                          itemBuilder: (context, index) {
                            final exam = state.exams[index];
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
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6FFEF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.assignment_rounded,
                                    color: Color(0xFF2DCE89),
                                  ),
                                ),
                                title: Text(
                                  exam.examInfo ?? "Unknown Exam",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF1A1C1E),
                                  ),
                                ),
                                subtitle: Text(
                                  "Class: ${exam.classInfo ?? 'N/A'} | Session: ${exam.year ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MarkDetailsPage(
                                        student: widget.student,
                                        marksClass: exam.classInfo ?? "",
                                        marksYear: exam.year ?? "",
                                        marksExam: exam.examInfo ?? "",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    } else if (state is ExamsFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Exams Unavailable",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1C1E),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 8,
                              ),
                              child: Text(
                                "We're having trouble reaching the school server. Please try again later.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchExams,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2DCE89),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
            value: _selectedSession,
            isExpanded: true,
            icon: Icon(Icons.calendar_month_rounded,
                color: Theme.of(context).primaryColor),
            style: const TextStyle(
              color: Color(0xFF1A1C1E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            items: _sessions.map((String sess) {
              return DropdownMenuItem(
                value: sess,
                child: Text("Session: $sess"),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSession = value;
                });
                _fetchExams();
              }
            },
          ),
        ),
      ),
    );
  }
}
