import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:current_diary_app/core/utils/app_toast.dart';
import 'package:current_diary_app/core/constants/app_colors.dart';
import 'package:current_diary_app/core/presentation/widgets/app_loading_indicator.dart';
import 'package:current_diary_app/widgets/primary_button.dart';
import 'package:current_diary_app/widgets/webview_page.dart';
import 'package:current_diary_app/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_urls.dart';
import '../bloc/auth_state.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/services/analytics_service.dart';

class SchoolCodePage extends StatefulWidget {
  const SchoolCodePage({super.key});

  @override
  State<SchoolCodePage> createState() => _SchoolCodePageState();
}

class _SchoolCodePageState extends State<SchoolCodePage> {
  final TextEditingController controller = TextEditingController();
  List<dynamic> _calendarData = [];
  bool _isCalendarLoading = false;
  String? _loadedCalendarSchoolCode;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchCalendarData(String schoolCode) async {
    if (_isCalendarLoading || _loadedCalendarSchoolCode == schoolCode) return;

    setState(() => _isCalendarLoading = true);
    try {
      final now = DateTime.now();
      final months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ];
      final currentMonth = months[now.month - 1];

      final formData = FormData.fromMap({
        'login': 'general',
        'month': currentMonth,
      });

      final dio = di.sl<Dio>();
      final response = await dio.post(
        AppUrls.getCalendar(schoolCode),
        data: formData,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('data')) {
          list = data['data'] as List;
        }

        if (mounted) {
          setState(() {
            _calendarData = list;
            _loadedCalendarSchoolCode = schoolCode;
          });
        }
      }
    } catch (e) {
      debugPrint("Calendar Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isCalendarLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          AppToast.show(context, state.message);
          if (state.schoolCode != null) {
            _fetchCalendarData(state.schoolCode!);
          }
        } else if (state is StudentAuthenticated) {
          if (state.student.schoolCode != null) {
            _fetchCalendarData(state.student.schoolCode!);
          }
        } else if (state is AuthError) {
          AppToast.show(context, "Invalid School Code", isError: true);
        }
      },
      builder: (context, state) {
        bool isConnected = (state is AuthSuccess && state.school != null) ||
            (state is StudentAuthenticated);
        
        dynamic school;
        String schoolCode = '';

        if (state is AuthSuccess) {
          school = state.school;
          schoolCode = state.schoolCode ?? '';
        } else if (state is StudentAuthenticated) {
          school = state.student; // StudentModel has school info fields like schoolName, logo etc.
          schoolCode = state.student.schoolCode ?? '';
        }

        if (isConnected && school != null) {
          return _buildHomeSection(context, school, schoolCode);
        }

        return _buildSchoolCodeEntry(context, state);
      },
    );
  }

  Widget _buildSchoolCodeEntry(BuildContext context, AuthState state) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'school_logo',
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.12),
                                blurRadius: 40,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/student_login.png',
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        "Connect to Your School",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1A1C1E),
                              letterSpacing: -0.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Enter the unique school code provided by your institution to access your digital diary.",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.6,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: "Enter School Code",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                              letterSpacing: 0,
                              fontWeight: FontWeight.normal,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (state is AuthLoading)
                        const AppLoadingIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            title: "SUBMIT",
                            onPressed: () {
                              final code = controller.text.trim();
                              if (code.isEmpty) {
                                AppToast.show(
                                  context,
                                  "Please enter a school code",
                                  isError: true,
                                );
                                return;
                              }
                              di.sl<AnalyticsService>().logSchoolSearch(code);
                              context.read<AuthBloc>().add(
                                SubmitSchoolCode(code),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeSection(
    BuildContext context,
    dynamic school,
    String schoolCode,
  ) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium School Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Hero(
                            tag: 'school_logo',
                            child: Image.network(
                              school.schoolLogo ?? '',
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade100,
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          school.title ?? 'School Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1C1E),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'logout') {
                            _showDisconnectDialog(context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.link_off_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Change School",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_vert_rounded,
                            color: Color(0xFF1A1C1E),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Thought Banner
                if (school.todayThought != null &&
                    school.todayThought!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: _buildHomeThoughtBanner(
                      context,
                      school.thoughtInfo ?? 'Thoughts',
                      school.todayThought!,
                    ),
                  ),

                // Carousel Section (Moved to Bottom)
                if (school.carouselImages.isNotEmpty) ...[
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 160.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.92,
                      autoPlayInterval: const Duration(seconds: 4),
                    ),
                    items: school.carouselImages.map<Widget>((imageUrl) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            imageUrl as String,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.82,
                    children: [
                      _buildHomeMenuItem(
                        context,
                        'Staff Login',
                        'assets/images/staff_login.png',
                        const Color(0xffDCF8EF),
                        null,
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Student Login',
                        'assets/images/student_login.png',
                        const Color(0xffFFF1E6),
                        AppRoutes.studentLogin,
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Reception',
                        'assets/images/reception.png',
                        const Color(0xffE6EEFF),
                        null,
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Admission',
                        'assets/images/admission.png',
                        const Color(0xffF2E6FF),
                        null,
                        url: school.onlineAdmissionUrl,
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Send Query',
                        'assets/images/send_query.png',
                        const Color(0xffFFE6E6),
                        AppRoutes.query,
                        arguments: {'school': school, 'schoolCode': schoolCode},
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Notice',
                        'assets/images/notice.png',
                        const Color(0xffE6EEFF),
                        AppRoutes.notice,
                        arguments: schoolCode,
                      ),
                      // _buildHomeMenuItem(
                      //   context,
                      //   'Enquiry',
                      //   'assets/images/enquiry.png',
                      //   const Color(0xffE6FFEF),
                      //   null,
                      // ),
                      _buildHomeMenuItem(
                        context,
                        'Web Staff',
                        'assets/images/web_staff_login.png',
                        const Color(0xffE6EEFF),
                        null,
                        url:
                            "https://currentdiary.com/app-for-school/staff-login/",
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Web Student',
                        'assets/images/web_student_login.png',
                        const Color(0xffF2E6FF),
                        null,
                        url:
                            "https://www.currentdiary.com/student-account/?schoolcodevalue=$schoolCode",
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Pay Online',
                        'assets/images/pay_fee.png',
                        const Color(0xffE6FFEF),
                        null,
                        url:
                            "https://www.currentdiary.com/student-fee-payment/pay-fee-online/$schoolCode",
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Calendar',
                        'assets/images/calendar.png',
                        const Color(0xffDCF8EF),
                        AppRoutes.calendar,
                        arguments: schoolCode,
                      ),
                      _buildHomeMenuItem(
                        context,
                        'Web Visitor',
                        'assets/images/visitor.png',
                        const Color(0xffF2F2F2),
                        null,
                      ),
                    ],
                  ),
                ),

                _buildCalendarSection(),

                const SizedBox(height: 18),

                // Footer Support
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Support",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          if (school.contactNo != null &&
                              school.contactNo!.isNotEmpty) {
                            final Uri tel = Uri.parse(
                              'tel:${school.contactNo}',
                            );
                            if (await canLaunchUrl(tel)) {
                              await launchUrl(tel);
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                school.contactNo ?? "N/A",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (school.schoolEmail != null &&
                          school.schoolEmail!.isNotEmpty)
                        InkWell(
                          onTap: () async {
                            final Uri mail = Uri.parse(
                              'mailto:${school.schoolEmail}',
                            );
                            if (await canLaunchUrl(mail)) {
                              await launchUrl(mail);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.alternate_email_rounded,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  school.schoolEmail!,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w800,
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildNoticeList and _fetchNotices are removed as per instruction.

  Widget _buildCalendarSection() {
    if (_isCalendarLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: AppLoadingIndicator()),
      );
    }

    if (_calendarData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "School Calendar".toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _calendarData.length,
            itemBuilder: (context, index) {
              final item = _calendarData[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['holidays-name']?.toString() ?? 'Holiday',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF1A1C1E),
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${item['date']?.toString() ?? ''} ${item['month']?.toString() ?? ''}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
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

  Widget _buildHomeThoughtBanner(
    BuildContext context,
    String title,
    String thought,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              thought,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeMenuItem(
    BuildContext context,
    String title,
    String image,
    Color color,
    String? route, {
    String? url,
    Object? arguments,
    IconData? icon,
  }) {
    return InkWell(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route, arguments: arguments);
        } else if (url != null) {
          _openUrl(context, title, url);
        } else {
          AppToast.show(context, "$title is Coming Soon");
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: icon != null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Icon(
                              icon,
                              color: Colors.grey.shade400,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Image.asset(image, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1E),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.link_off_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Change School?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1C1E),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to change school? You will need the school code to connect again.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(DisconnectSchool());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Change",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openUrl(BuildContext context, String title, String? url) {
    if (title == "Gallery") {
      Navigator.pushNamed(context, AppRoutes.gallery);
      return;
    }

    if (title == "Student Login") {
      Navigator.pushNamed(context, AppRoutes.studentLogin);
      return;
    }

    if (title == "Notice") {
      Navigator.pushNamed(context, AppRoutes.notice);
      return;
    }

    if (url != null && url != "NA" && url.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(title: title, url: url),
        ),
      );
    } else {
      AppToast.show(context, "$title is Coming Soon");
      HapticFeedback.lightImpact();
    }
  }
}
