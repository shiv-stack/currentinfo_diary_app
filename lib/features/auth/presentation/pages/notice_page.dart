import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:linkify/linkify.dart';

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1C1E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "School Notices",
            style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading notices"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No notices available"));
        }

        final notices = snapshot.data!;
        return ListView.builder(
          itemCount: notices.length,
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final notice = notices[index];
            final fileUrl = notice['fileee'] as String? ?? "";
            
            final isImage = fileUrl.toLowerCase().contains(RegExp(r'\.(jpg|jpeg|png|gif|webp)'));
            final hasFile = fileUrl.isNotEmpty && !fileUrl.contains("/None");

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
                    // Header Date & Time (Centered)
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
                    // Image Section (Full image, natural height)
                    if (isImage && hasFile)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            fileUrl,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    // Title (Centered)
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
                    // Description (Left Aligned)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Linkify(
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
                            fontSize: 16,
                            color: const Color(0xFF1A1C1E).withValues(alpha: 0.8),
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
                    // TextButton for Attachments (If any)
                    if (hasFile && !isImage) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextButton.icon(
                          onPressed: () => _handleFileDownload(fileUrl),
                          icon: Icon(Icons.attachment_rounded, color: Theme.of(context).primaryColor, size: 20),
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
      },
    );
  }

  Future<List<dynamic>> _fetchNotices(String schoolCode) async {
    try {
      final dio = Dio();
      final response = await dio.get("https://www.currentdiary.com/school-notice/api-school-info-detail-school/$schoolCode/");
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
