import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:current_diary_app/core/utils/app_toast.dart';
import '../../../../injection_container.dart' as di;
import '../../data/datasources/auth_local_data_source.dart';

import '../../../student/presentation/bloc/student_bloc.dart';
import '../../../student/presentation/bloc/student_event.dart';
import '../../../student/presentation/bloc/student_state.dart';
import '../../../student/presentation/pages/student_dashboard_page.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  void _onLoginPressed(BuildContext context) async {
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      AppToast.show(context, "Please enter name and password", isError: true);
      return;
    }

    final code = await di.sl<AuthLocalDataSource>().getCachedSchoolCode();
    if (code == null || code.isEmpty) {
      AppToast.show(
        context,
        "School code missing. Please connect again.",
        isError: true,
      );
      return;
    }

    if (!context.mounted) return;
    context.read<StudentBloc>().add(
      StudentLoginSubmitted(schoolCode: code, name: name, uniqueCode: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentLoginSuccess) {
            AppToast.show(context, "Login Successful");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => StudentDashboardPage(student: state.student),
              ),
              (route) => false,
            );
          } else if (state is StudentLoginFailure) {
            AppToast.show(
              context,
              "Invalid Student Name or Password",
              isError: true,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Background repeating pattern (PRESERVED)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/student_login.png',
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.none,
                    scale: 3.0,
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Welcome Header
                            Text(
                              "Student Portal",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Welcome Back!",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1C1E),
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Please enter your credentials to access your diary.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Login Form Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.04,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _nameController,
                                    label: "Student Name",
                                    icon: Icons.person_rounded,
                                    context: context,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: "Password",
                                    icon: Icons.lock_rounded,
                                    isPassword: true,
                                    isVisible: _isPasswordVisible,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                    context: context,
                                  ),
                                  const SizedBox(height: 32),

                                  // Submit Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: BlocBuilder<StudentBloc, StudentState>(
                                      builder: (context, state) {
                                        final isLoading =
                                            state is StudentLoading;
                                        return ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () => _onLoginPressed(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(
                                              context,
                                            ).primaryColor,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text(
                                                  "SIGN IN",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 1.0,
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = true,
    VoidCallback? onToggleVisibility,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade400,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
