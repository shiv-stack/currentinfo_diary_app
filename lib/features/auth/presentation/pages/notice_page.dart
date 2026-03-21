import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1C1E),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Column(
            children: [
              Text(
                "School Notices",
                style: TextStyle(
                  color: Color(0xFF1A1C1E),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                "Official Updates & Announcements",
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
        body: _buildNoticeList(context),
      ),
    );
  }

  Widget _buildNoticeList(BuildContext context) {
    final schoolCode = (ModalRoute.of(context)?.settings.arguments as String?) ?? "20";

    return FutureBuilder<List<dynamic>>(
      future: _fetchNotices(schoolCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoadingIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorState("Error loading notices");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final notices = snapshot.data!;
        return ListView.builder(
          itemCount: notices.length,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemBuilder: (context, index) {
            return _buildNoticeCard(context, notices[index]);
          },
        );
      },
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
          // Modern Header
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
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      notice['time']?.toString().toUpperCase() ?? 'RECENT',
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
                  notice['title'] ?? 'Important Notice',
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
            "Everything is up to date.",
            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Future<List<dynamic>> _fetchNotices(String schoolCode) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        "https://www.currentdiary.com/school-notice/api-school-info-detail-school/$schoolCode/",
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
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
