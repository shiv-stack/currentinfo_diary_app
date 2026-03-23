import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:current_diary_app/core/utils/app_toast.dart';
import '../../../../injection_container.dart' as di;
import '../../data/datasources/auth_local_data_source.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';

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
  String? _currentSchoolCode;
  String? _schoolName;

  @override
  void initState() {
    super.initState();
    _loadSchoolCodeAndSavedStudents();
  }

  void _loadSchoolCodeAndSavedStudents() async {
    final code = await di.sl<AuthLocalDataSource>().getCachedSchoolCode();
    final school = await di.sl<AuthLocalDataSource>().getCachedSchoolInfo();
    if (mounted) {
      setState(() {
        _currentSchoolCode = code;
        _schoolName = school?.title;
      });
      context.read<StudentBloc>().add(GetSavedStudents());
    }
  }

  void _onLoginPressed(
    BuildContext context, {
    String? name,
    String? password,
    String? schoolCode,
  }) async {
    final effectiveName = name ?? _nameController.text.trim();
    final effectivePassword = password ?? _passwordController.text.trim();

    if (effectiveName.isEmpty || effectivePassword.isEmpty) {
      AppToast.show(context, "Please enter name and password", isError: true);
      return;
    }

    // If schoolCode is provided (from saved student), we use it.
    // Otherwise, we get it from the cache.
    String? code = schoolCode;
    if (code == null || code.isEmpty) {
      code = await di.sl<AuthLocalDataSource>().getCachedSchoolCode();
    }

    if (code == null || code.isEmpty) {
      AppToast.show(
        context,
        "School code missing. Please connect again.",
        isError: true,
      );
      return;
    }

    // Production Ready: If we are logging in with a specific school code (e.g. switching accounts),
    // we should update our cached school code context so future API calls use the correct URL.
    if (schoolCode != null) {
      await di.sl<AuthLocalDataSource>().cacheSchoolCode(schoolCode);
    }

    if (!context.mounted) return;
    context.read<StudentBloc>().add(
      StudentLoginSubmitted(
        schoolCode: code,
        name: effectiveName,
        uniqueCode: effectivePassword,
      ),
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
            // Refresh saved students list after successful login
            context.read<StudentBloc>().add(GetSavedStudents());
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
                              _schoolName ?? "Student Portal",
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
                            const SizedBox(height: 8),
                            Text(
                              "Please enter your credentials to access your diary.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Login Form Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
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
                                  const SizedBox(height: 15),

                                  // Submit Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child:
                                        BlocBuilder<StudentBloc, StudentState>(
                                          builder: (context, state) {
                                            final isLoading =
                                                state is StudentLoading;
                                            return ElevatedButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () => _onLoginPressed(
                                                      context,
                                                    ),
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
                                                          AppLoadingIndicator(
                                                            centered: false,
                                                            color: Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                    )
                                                  : const Text(
                                                      "SIGN IN",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
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
                            const SizedBox(height: 15),
                            _buildSavedStudentsSection(),
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

  Widget _buildSavedStudentsSection() {
    return BlocBuilder<StudentBloc, StudentState>(
      buildWhen: (previous, current) => current is SavedStudentsLoaded,
      builder: (context, state) {
        if (state is SavedStudentsLoaded && state.savedStudents.isNotEmpty) {
          final filteredStudents = state.savedStudents
              .where((s) => s.schoolCode == _currentSchoolCode)
              .toList();

          if (filteredStudents.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Switch Account".toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    "${filteredStudents.length}/5",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120, // Increased height for better card layout
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              InkWell(
                                onTap: () => _onLoginPressed(
                                  context,
                                  name: student.name,
                                  password: student.uniqueCode,
                                  schoolCode: student.schoolCode,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.15),
                                        Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.1),
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      student.profileImage != null &&
                                          student.profileImage!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          child: Image.network(
                                            student.profileImage!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    _buildInitials(
                                                      student.name,
                                                    ),
                                          ),
                                        )
                                      : _buildInitials(student.name),
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: InkWell(
                                  onTap: () => _showDeleteConfirmDialog(
                                    student.uniqueCode,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              student.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1C1E),
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteConfirmDialog(String uniqueCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text("Are you sure you want to remove this account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              context.read<StudentBloc>().add(DeleteSavedStudent(uniqueCode));
              Navigator.pop(context);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
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

  Widget _buildInitials(String name) {
    return Center(
      child: Text(
        (() {
          final names = name.trim().split(RegExp(r'\s+'));
          if (names.isEmpty) return "?";
          if (names.length == 1) return names[0][0].toUpperCase();
          return (names[0][0] + names[1][0]).toUpperCase();
        })(),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).primaryColor,
          letterSpacing: -1,
        ),
      ),
    );
  }
}
