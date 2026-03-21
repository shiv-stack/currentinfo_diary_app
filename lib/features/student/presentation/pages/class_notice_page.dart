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
          toolbarHeight: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1C1E), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Column(
            children: [
              Text(
                "Class Update",
                style: TextStyle(
                  color: Color(0xFF1A1C1E),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                "Direct messages from your teachers",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            if (state is ClassNoticesLoading) {
              return const AppLoadingIndicator();
            } else if (state is ClassNoticesFailure) {
              return Center(child: Text(state.message, style: const TextStyle(fontWeight: FontWeight.w700)));
            } else if (state is ClassNoticesLoaded) {
              if (state.notices.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                itemCount: state.notices.length,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemBuilder: (context, index) {
                  return _buildNoticeCard(context, state.notices[index]);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNoticeCard(BuildContext context, dynamic notice) {
    final fileUrl = notice['fileee'] as String? ?? "";
    final isImage = fileUrl.toLowerCase().contains(RegExp(r'\.(jpg|jpeg|png|gif|webp)'));
    final hasFile = fileUrl.isNotEmpty && !fileUrl.contains("/None");
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      notice['time']?.toString().toUpperCase() ?? 'CLASS UPDATE',
                      style: TextStyle(
                        color: primaryColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                if (hasFile && !isImage)
                  InkWell(
                    onTap: () => _handleFileDownload(fileUrl),
                    child: Row(
                      children: [
                        Text(
                          "VIEW",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                      ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_right_alt_rounded, color: primaryColor, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isImage && hasFile)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  fileUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice['title'] ?? 'Section Update',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1C1E),
                    letterSpacing: -0.6,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Linkify(
                  onOpen: (link) async {
                    try {
                      final uri = Uri.parse(link.url);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      debugPrint("Link opening error: $e");
                    }
                  },
                  text: notice['description'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF1A1C1E).withValues(alpha: 0.65),
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                  ),
                  linkStyle: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
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
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 10)),
              ],
            ),
            child: Icon(Icons.notifications_none_rounded, size: 70, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 30),
          const Text(
            "No active notices",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1C1E), letterSpacing: -0.5),
          ),
          const SizedBox(height: 10),
          Text(
            "Stay tuned for messages from your school.",
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
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
