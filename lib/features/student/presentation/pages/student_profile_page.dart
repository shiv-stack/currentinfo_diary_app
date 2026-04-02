import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../auth/presentation/pages/student_login_page.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/utils/app_toast.dart';

class StudentProfilePage extends StatelessWidget {
  final StudentModel student;
  const StudentProfilePage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is PasswordUpdateSaving) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AppLoadingIndicator(),
            );
          } else if (state is PasswordUpdateSuccess) {
            Navigator.pop(context); // Close loading
            Navigator.pop(context); // Close bottom sheet
            AppToast.show(context, state.message);
            // Navigate back to login page and clear the navigation stack
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const StudentLoginPage()),
              (route) => false,
            );
          } else if (state is PasswordUpdateFailure) {
            Navigator.pop(context); // Close loading
            AppToast.show(context, state.message, isError: true);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: Column(
            children: [
              _buildHeader(context, primaryColor),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(
                    children: [
                      _buildDetailCard(context),
                      const SizedBox(height: 22),
                      _buildActionButton(context, primaryColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 30,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const Text(
                "PROFILE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 48), // Spacer for balance
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 3,
                  ),
                  image:
                      student.studentImage != null &&
                          student.studentImage!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(student.studentImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    student.studentImage == null ||
                        student.studentImage!.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        size: 35,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name ?? "Student",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Class ${student.className ?? 'N/A'} • Section ${student.section ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today_rounded,
            "DATE OF BIRTH",
            student.dob ?? "N/A",
            Colors.blue,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.numbers,
            "Enrollment No",
            student.enrollNumber ?? "N/A",
            Colors.orange,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.phone_iphone_rounded,
            "CONTACT",
            student.contactNumber ?? "N/A",
            Colors.green,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.password,
            "PASSWORD",
            student.password ?? "N/A",
            Colors.green,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.business_rounded,
            "Date of Addmission",
            student.doa ?? "N/A",
            Colors.purple,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.face_rounded,
            "FATHER'S NAME",
            student.fatherName ?? "N/A",
            Colors.indigo,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.face_3_rounded,
            "MOTHER'S NAME",
            student.motherName ?? "N/A",
            Colors.pink,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.location_on_rounded,
            "ADDRESS",
            student.address ?? "Not Provided",
            Colors.red,
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.alternate_email_rounded,
            "EMAIL",
            student.email ?? "N/A",
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1A1C1E),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade50,
      indent: 60,
      endIndent: 20,
    );
  }

  Widget _buildActionButton(BuildContext context, Color primaryColor) {
    return InkWell(
      onTap: () => _showPasswordResetBottomSheet(context, primaryColor),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_reset_rounded, color: Colors.red, size: 20),
            SizedBox(width: 10),
            Text(
              "RESET LOGIN PASSWORD",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordResetBottomSheet(BuildContext context, Color primaryColor) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Update Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "New password must be digits only.",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Note: A re-login is required after the reset.",
                  style: TextStyle(
                    color: Colors.blue.shade400,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPasswordField(
                  controller: currentPassController,
                  label: "Current Password",
                  hint: "Enter your current password",
                  icon: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: newPassController,
                  label: "New Password",
                  hint: "Enter new numerical password",
                  icon: Icons.lock_reset_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field is required";
                    }
                    if (value.length < 6) return "Minimum 6 digits required";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: confirmPassController,
                  label: "Confirm Password",
                  hint: "Re-type new password",
                  icon: Icons.check_circle_outline_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field is required";
                    }
                    if (value != newPassController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<StudentBloc>().add(
                          UpdatePassword(
                            schoolCode: student.schoolCode ?? "",
                            studentId: student.cdiaryId ?? "",
                            currentPassword: currentPassController.text,
                            newPassword: newPassController.text,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                      shadowColor: primaryColor.withValues(alpha: 0.3),
                    ),
                    child: const Text(
                      "UPDATE PASSWORD",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) return "Field is required";
                return null;
              },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }
}
