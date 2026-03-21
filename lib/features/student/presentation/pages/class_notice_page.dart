import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../injection_container.dart' as di;

class ClassNoticePage extends StatefulWidget {
  final StudentModel student;
  const ClassNoticePage({super.key, required this.student});

  @override
  State<ClassNoticePage> createState() => _ClassNoticePageState();
}

class _ClassNoticePageState extends State<ClassNoticePage> {
  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  void _fetchNotices() async {
    final authLocal = di.sl<AuthLocalDataSource>();
    final schoolCode = await authLocal.getCachedSchoolCode();
    final session = await authLocal.getCachedSession() ?? "2025-2026";
    final creds = await authLocal.getCachedStudentCredentials(schoolCode ?? "");

    if (schoolCode != null && creds != null && mounted) {
      context.read<StudentBloc>().add(
            GetClassNotices(
              schoolCode: schoolCode,
              cdiaryId: widget.student.cdiaryId ?? "",
              password: creds['password'] ?? "",
              session: session,
              className: widget.student.className ?? "",
              section: widget.student.section ?? "",
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
            "Class Notices",
            style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            if (state is ClassNoticesLoading) {
              return const AppLoadingIndicator();
            } else if (state is ClassNoticesFailure) {
              return Center(child: Text(state.message));
            } else if (state is ClassNoticesLoaded) {
              if (state.notices.isEmpty) {
                return const Center(child: Text("No class notices available"));
              }
              return ListView.builder(
                itemCount: state.notices.length,
                padding: const EdgeInsets.all(20),
                itemBuilder: (context, index) {
                  final notice = state.notices[index];
                  final fileUrl = notice['fileee'] as String? ?? "";
                  final isImage = fileUrl
                      .toLowerCase()
                      .contains(RegExp(r'\.(jpg|jpeg|png|gif|webp)'));
                  final hasFile =
                      fileUrl.isNotEmpty && !fileUrl.contains("/None");

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              notice['time'] ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1C1E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (isImage && hasFile)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  fileUrl,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              notice['title'] ?? 'Notice',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1C1E),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Linkify(
                                onOpen: (link) async {
                                  try {
                                    final uri = Uri.parse(link.url);
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    debugPrint("Link opening error: $e");
                                  }
                                },
                                text: notice['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: const Color(0xFF1A1C1E)
                                      .withValues(alpha: 0.8),
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                linkStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          if (hasFile && !isImage) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: TextButton.icon(
                                onPressed: () => _handleFileDownload(fileUrl),
                                icon: Icon(Icons.attachment_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 20),
                                label: Text(
                                  "View Attachment",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _handleFileDownload(String url) async {
    try {
      String finalUrl = url.trim();
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }
      final uri = Uri.parse(finalUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
}

