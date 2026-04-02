import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../data/models/student_model.dart';
import '../../../../injection_container.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';

class AssignmentPage extends StatefulWidget {
  final StudentModel student;

  const AssignmentPage({super.key, required this.student});

  @override
  State<AssignmentPage> createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  String selectedFilter = "Monthwise";
  DateTime selectedDate = DateTime.now();
  late final ScrollController _monthController;
  late final ScrollController _dateController;

  @override
  void initState() {
    super.initState();
    _monthController = ScrollController();
    _dateController = ScrollController();
    _fetchAssignments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedFilter == "Monthwise") _scrollToSelectedMonth();
      if (selectedFilter == "Datewise") _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _scrollToSelectedMonth() {
    if (!_monthController.hasClients) return;
    final index = selectedDate.month - 1;
    const itemWidth = 100.0 + 8.0; // item width + horizontal margins
    final screenWidth = MediaQuery.of(context).size.width;
    final offset =
        (index * itemWidth) + 16.0 - (screenWidth / 2) + (itemWidth / 2);
    _monthController.animateTo(
      offset.clamp(0.0, _monthController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToSelectedDate() {
    if (!_dateController.hasClients) return;
    final index = selectedDate.day - 1;
    const itemWidth = 55.0 + 8.0; // width + horizontal margins
    final screenWidth = MediaQuery.of(context).size.width;
    final offset =
        (index * itemWidth) + 16.0 - (screenWidth / 2) + (itemWidth / 2);
    _dateController.animateTo(
      offset.clamp(0.0, _dateController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchAssignments() async {
    final authLocal = sl<AuthLocalDataSource>();
    final schoolCode = await authLocal.getCachedSchoolCode();
    final session = await authLocal.getCachedSession() ?? "2025-2026";
    final creds = await authLocal.getCachedStudentCredentials(schoolCode ?? "");

    if (schoolCode != null && creds != null && mounted) {
      context.read<StudentBloc>().add(
        GetAssignments(
          schoolCode: schoolCode,
          cdiaryId: widget.student.cdiaryId ?? "",
          password: creds['password'] ?? "",
          session: session,
          month: DateFormat('MMMM').format(selectedDate),
          day: DateFormat('dd').format(selectedDate),
          studentClass: widget.student.className ?? "",
          section: widget.student.section ?? "",
          showhw: selectedFilter,
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
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1C1E),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            "HOME WORK",
            style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.8,
            ),
          ),
          centerTitle: true,
          actions: [
            // Padding(
            //   padding: const EdgeInsets.only(right: 15),
            //   child: IconButton(
            //     onPressed: () => _selectDate(context),
            //     icon: const Icon(
            //       Icons.calendar_month_rounded,
            //       color: Color(0xFF1A1C1E),
            //       size: 26,
            //     ),
            //   ),
            // ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterTabs(),
            if (selectedFilter == "Monthwise") _buildHorizontalMonthSelector(),
            if (selectedFilter == "Datewise") _buildHorizontalDateSelector(),
            Expanded(
              child: BlocBuilder<StudentBloc, StudentState>(
                builder: (context, state) {
                  if (state is AssignmentsLoading) {
                    return const AppLoadingIndicator();
                  } else if (state is AssignmentsLoaded) {
                    if (state.assignments.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: state.assignments.length,
                      itemBuilder: (context, index) {
                        return _buildAssignmentCard(state.assignments[index]);
                      },
                    );
                  } else if (state is AssignmentsFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalMonthSelector() {
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
    final currentMonth = DateFormat('MMMM').format(selectedDate);

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        controller: _monthController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = month == currentMonth;
          final primaryColor = Theme.of(context).primaryColor;

          return GestureDetector(
            onTap: () {
              setState(() {
                // Keep the same day but change month
                selectedDate = DateTime(selectedDate.year, index + 1, 1);
              });
              _scrollToSelectedMonth();
              _fetchAssignments();
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade200,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                month,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalDateSelector() {
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final currentDay = selectedDate.day;

    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        controller: _dateController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = day == currentDay;
          final date = DateTime(selectedDate.year, selectedDate.month, day);
          final dayName = DateFormat('EEE').format(date);
          final primaryColor = Theme.of(context).primaryColor;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  day,
                );
              });
              _scrollToSelectedDate();
              _fetchAssignments();
            },
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade200,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1A1C1E),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [_buildTabItem("Monthwise"), _buildTabItem("Datewise")],
      ),
    );
  }

  Widget _buildTabItem(String title) {
    bool isSelected = selectedFilter == title;
    final Color primaryColor = Theme.of(context).primaryColor;
    return Expanded(
      child: GestureDetector(
          onTap: () {
            setState(() {
              selectedFilter = title;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (selectedFilter == "Monthwise") _scrollToSelectedMonth();
              if (selectedFilter == "Datewise") _scrollToSelectedDate();
            });
            _fetchAssignments();
          },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(dynamic assignment) {
    final String subject =
        (assignment['title'] != null &&
            assignment['title'].toString().isNotEmpty)
        ? assignment['title']
        : (assignment['by'] ?? "Assignment");
    final String date = assignment['date'] ?? "";
    final String content = assignment['desc'] ?? "";
    final String? fileUrl = assignment['doc'];

    final bool isImage =
        fileUrl != null &&
        fileUrl.toLowerCase().contains(RegExp(r'\.(jpg|jpeg|png|gif|webp)'));
    final hasFile =
        fileUrl != null && fileUrl.isNotEmpty && !fileUrl.contains("/None");
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                      date.toUpperCase(),
                      style: TextStyle(
                        color: primaryColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                if (hasFile && !isImage)
                  InkWell(
                    onTap: () => _handleFileLaunch(fileUrl),
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
                        Icon(
                          Icons.arrow_right_alt_rounded,
                          color: primaryColor,
                          size: 16,
                        ),
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
                child: InteractiveViewer(
                  child: Image.network(
                    fileUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
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
                  onOpen: (link) => _handleFileLaunch(link.url),
                  text: content,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              size: 70,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "No Assignments found!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1C1E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You are all caught up!",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFileLaunch(String url) async {
    try {
      final uri = Uri.parse(url.trim());
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open document')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(2025),
  //     lastDate: DateTime(2026),
  //   );
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //     _fetchAssignments();
  //   }
  // }
}
