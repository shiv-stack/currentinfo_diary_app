import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/student_model.dart';
import '../../data/models/leave_model.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';

class LeavePage extends StatefulWidget {
  final StudentModel student;

  const LeavePage({super.key, required this.student});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    final authLocal = sl<AuthLocalDataSource>();
    final code = await authLocal.getCachedSchoolCode();
    final creds = await authLocal.getActiveStudentCredentials();
    if (code != null && creds != null) {
      if (!mounted) return;
      context.read<StudentBloc>().add(
        GetLeaves(
          schoolCode: code,
          studentId: widget.student.cdiaryId ?? '',
          password: creds['password'] ?? '',
        ),
      );
    }
  }

  void _submitRequest() async {
    if (_fromDate == null ||
        _toDate == null ||
        _reasonController.text.isEmpty) {
      AppToast.show(context, "Please fill all details", isError: true);
      return;
    }

    final authLocal = sl<AuthLocalDataSource>();
    final code = await authLocal.getCachedSchoolCode();
    final creds = await authLocal.getActiveStudentCredentials();
    final session = await authLocal.getCachedSession();

    if (code != null && creds != null) {
      if (!mounted) return;
      context.read<StudentBloc>().add(
        ApplyLeave(
          schoolCode: code,
          studentId: widget.student.cdiaryId ?? '',
          password: creds['password'] ?? '',
          studentName: widget.student.name ?? '',
          studentClass: widget.student.className ?? '',
          admissionRollNo:
              widget.student.cdiaryId ??
              '', // Assuming this is cdiaryid based on params
          session: session ?? widget.student.session ?? '',
          fromDate: DateFormat('dd-MM-yyyy').format(_fromDate!),
          toDate: DateFormat('dd-MM-yyyy').format(_toDate!),
          reason: _reasonController.text,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // For 'To' date, the minimum date should be the 'From' date (or today if not set)
    final firstDate = isFromDate ? today : (_fromDate ?? today);

    // Ensure initial date is not before firstDate
    DateTime initialDate = isFromDate
        ? (_fromDate ?? today)
        : (_toDate ?? firstDate);
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1A1C1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          // If the new 'From' date is after the existing 'To' date, clear 'To' date
          if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
            _toDate = null;
          }
        } else {
          _toDate = picked;
        }
      });
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
      child: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is LeaveApplySuccess) {
            // Check if the 200 message is actually a server-side "Already Applied" warning
            final bool isActualError = state.message.contains(
              "Already Applied",
            );
            AppToast.show(context, state.message, isError: isActualError);

            if (!isActualError) {
              // On real success, clear the form and refresh the history list
              _reasonController.clear();
              setState(() {
                _fromDate = null;
                _toDate = null;
              });

              // REFRESH HISTORY
              _fetchHistory();
            }
          } else if (state is LeaveApplyFailure) {
            AppToast.show(context, state.message, isError: true);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1C1E),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Apply Leave",
              style: TextStyle(
                color: Color(0xFF1A1C1E),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequestCard(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    "Leave History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1C1E),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildLeaveHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_calendar_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "New Request",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: "From",
                  date: _fromDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker(
                  label: "To",
                  date: _toDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel("Reason for Leave"),
          const SizedBox(height: 6),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            maxLength: 300,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Enter reason...",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
              counterStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 20),
          BlocBuilder<StudentBloc, StudentState>(
            buildWhen: (previous, current) =>
                current is LeaveApplying ||
                current is LeaveApplySuccess ||
                current is LeaveApplyFailure,
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: state is LeaveApplying ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state is LeaveApplying
                      ? const AppLoadingIndicator(
                          centered: false,
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          "RAISE REQUEST",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('dd MMM yyyy').format(date)
                        : "Select",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: date != null
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: date != null
                          ? const Color(0xFF1A1C1E)
                          : Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildLeaveHistory() {
    return BlocBuilder<StudentBloc, StudentState>(
      buildWhen: (p, c) =>
          c is LeavesLoading || c is LeavesLoaded || c is LeavesFailure,
      builder: (context, state) {
        if (state is LeavesLoading) {
          return const Center(child: AppLoadingIndicator());
        } else if (state is LeavesFailure) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          );
        } else if (state is LeavesLoaded) {
          if (state.leaves.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "No leave history found",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.leaves.length,
            itemBuilder: (context, index) =>
                _buildHistoryCard(state.leaves[index]),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHistoryCard(LeaveModel leave) {
    final status = leave.status?.toUpperCase() ?? "PENDING";
    final color = status == "APPROVED"
        ? Colors.green
        : status == "REJECTED"
        ? Colors.red
        : Colors.orange;

    String requestDate = leave.requestDate ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "Requested on $requestDate",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Student - ${leave.teacherName ?? ''} @ ${leave.teacherClass ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1C1E),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildHistoryDateColumn("FROM", leave.fromDate ?? 'N/A'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 20,
                  height: 1,
                  color: Colors.grey.shade200,
                ),
              ),
              _buildHistoryDateColumn("TO", leave.toDate ?? 'N/A'),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            leave.reason ?? "No reason provided",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDateColumn(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1C1E),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
