import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;

class SchoolCalendarPage extends StatefulWidget {
  const SchoolCalendarPage({super.key});

  @override
  State<SchoolCalendarPage> createState() => _SchoolCalendarPageState();
}

class _SchoolCalendarPageState extends State<SchoolCalendarPage> {
  late int _selectedMonthIndex;
  late String _schoolCode;

  final List<String> _months = [
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

  @override
  void initState() {
    super.initState();
    _selectedMonthIndex = DateTime.now().month - 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schoolCode =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? "20";
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonthIndex < 11) {
        _selectedMonthIndex++;
      } else {
        _selectedMonthIndex = 0;
      }
    });
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonthIndex > 0) {
        _selectedMonthIndex--;
      } else {
        _selectedMonthIndex = 11;
      }
    });
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1C1E),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "School Calendar",
            style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildMonthSelector(),
            Expanded(child: _buildCalendarList()),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          Text(
            _months[_selectedMonthIndex],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1E),
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarList() {
    return FutureBuilder<List<dynamic>>(
      key: ValueKey(_selectedMonthIndex), // Triggers refresh on month change
      future: _fetchCalendar(_schoolCode, _months[_selectedMonthIndex]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoadingIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading calendar"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  "No events scheduled for ${_months[_selectedMonthIndex]}",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final events = snapshot.data!;
        return ListView.builder(
          itemCount: events.length,
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            final event = events[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event['date']?.toString() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        (event['month']?.toString() ?? '').length >= 3
                            ? (event['month']?.toString() ?? '').substring(0, 3)
                            : (event['month']?.toString() ?? ''),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  event['holidays-name']?.toString() ?? 'School Event',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "${event['date']?.toString() ?? ''} ${event['month']?.toString() ?? ''} ${event['year']?.toString() ?? ''}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchCalendar(String schoolCode, String month) async {
    try {
      final dio = di.sl<Dio>();
      final response = await dio.post(
        AppUrls.getCalendar(schoolCode),
        data: {
          'login': 'general',
          'month': month,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
