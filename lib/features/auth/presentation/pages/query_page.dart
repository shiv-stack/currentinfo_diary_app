import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:current_diary_app/core/utils/app_toast.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../data/models/school_model.dart';
import '../bloc/query_bloc.dart';
import '../bloc/query_event.dart';
import '../bloc/query_state.dart';

class QueryPage extends StatefulWidget {
  final SchoolModel school;
  final String schoolCode;

  const QueryPage({
    super.key,
    required this.school,
    required this.schoolCode,
  });

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    final title = _titleController.text.trim();
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || name.isEmpty || mobile.isEmpty || message.isEmpty) {
      AppToast.show(context, "Please fill all fields", isError: true);
      return;
    }

    if (mobile.length != 10) {
      AppToast.show(context, "Please enter a valid 10-digit mobile number", isError: true);
      return;
    }

    context.read<QueryBloc>().add(
          SendQueryEvent(
            schoolCode: widget.schoolCode,
            title: title,
            name: name,
            mobile: mobile,
            message: message,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return BlocListener<QueryBloc, QueryState>(
      listener: (context, state) {
        if (state is QuerySuccess) {
          AppToast.show(context, "Query sent successfully");
          Navigator.pop(context);
        } else if (state is QueryError) {
          AppToast.show(context, state.message, isError: true);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1C1E),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              children: [
                Text(
                  "Send Query",
                  style: TextStyle(
                    color: Color(0xFF1A1C1E),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: -0.8,
                  ),
                ),
                Text(
                  "Contact School Directly",
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Unified Information Card (Notice-style)
                Container(
                  width: double.infinity,
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
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.04),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "SCHOOL CONTACT DETAILS",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.school.title ?? 'School Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1C1E),
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(Icons.location_on_rounded, widget.school.schoolAddress ?? "Address"),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.alternate_email_rounded, widget.school.schoolEmail ?? "Email"),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.phone_iphone_rounded, widget.school.contactNo ?? "Phone"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
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
                      const Text(
                        "Your Inquiry",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1C1E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField("Title / Subject", _titleController, Icons.label_important_outline_rounded),
                      _buildInputField("Full Name", _nameController, Icons.person_outline_rounded),
                      _buildInputField(
                        "Mobile Number",
                        _mobileController,
                        Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      _buildInputField("Message", _messageController, Icons.chat_bubble_outline_rounded, maxLines: 4),
                      const SizedBox(height: 20),
                      BlocBuilder<QueryBloc, QueryState>(
                        builder: (context, state) {
                          if (state is QueryLoading) {
                            return const Center(child: AppLoadingIndicator());
                          }
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _onSendPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text(
                                "SEND QUERY",
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF1A1C1E).withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          counterText: "",
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
