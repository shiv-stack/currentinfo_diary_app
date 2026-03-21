import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:current_diary_app/core/utils/app_toast.dart';
import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../injection_container.dart' as di;

class FeePage extends StatefulWidget {
  final StudentModel student;
  const FeePage({super.key, required this.student});

  @override
  State<FeePage> createState() => _FeePageState();
}

class _FeePageState extends State<FeePage> {
  String? _schoolCode;
  String? _session;
  String? _feeSoftware;

  @override
  void initState() {
    super.initState();
    _fetchFees();
  }

  void _fetchFees() async {
    final authLocal = di.sl<AuthLocalDataSource>();
    final schoolCode = await authLocal.getCachedSchoolCode();
    final session = await authLocal.getCachedSession() ?? "2025-2026";
    final creds = await authLocal.getCachedStudentCredentials(schoolCode ?? "");
    final feeSoftware = await authLocal.getCachedFeeSoftware() ?? "quick";

    if (mounted) {
      setState(() {
        _schoolCode = schoolCode;
        _session = session;
        _feeSoftware = feeSoftware;
      });
    }

    if (schoolCode != null && creds != null && mounted) {
      context.read<StudentBloc>().add(
        GetFees(
          schoolCode: schoolCode,
          cdiaryId: widget.student.cdiaryId ?? "",
          password: creds['password'] ?? "",
          session: session,
          studentFeeSoftware: feeSoftware,
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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1C1E),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Fee Details",
                style: TextStyle(
                  color: Color(0xFF1A1C1E),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              if (_session != null)
                Text(
                  "Session: $_session",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            if (state is FeesLoading) {
              return const AppLoadingIndicator();
            } else if (state is FeesFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchFees,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is FeesLoaded) {
              if (state.fees.isEmpty) {
                return _buildEmptyFees();
              }
              return _buildFeeList(state.fees);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyFees() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            "No fee records found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeList(List<dynamic> fees) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: fees.length,
      itemBuilder: (context, index) {
        final fee = fees[index];
        return _buildFeeCard(fee);
      },
    );
  }

  Widget _buildFeeCard(dynamic fee) {
    final String head = fee['headname1'] ?? "Fee Detail";
    final String amount = fee['f-amount'] ?? "0";
    final String date = fee['date'] ?? "";
    final String receiptNo = fee['fee_receipt_no'] ?? "N/A";
    final String fatherName = fee['f_name'] ?? "";
    final String dues = fee['dues'] ?? "0";
    final String months = fee['f-m-submitted'] ?? "";
    final String paymentMode = fee['payment-mode'] ?? "N/A";

    // Status logic: if dues is 0 and amount > 0, consider paid.
    // Otherwise, if dues > 0, it's pending.
    final double duesVal = double.tryParse(dues.toString()) ?? 0;
    final bool isPaid = duesVal <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPaid
                        ? Icons.check_circle_rounded
                        : Icons.pending_actions_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        head,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      Text(
                        isPaid ? "Payment Successful" : "Balance Due: ₹$dues",
                        style: TextStyle(
                          fontSize: 12,
                          color: isPaid
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹$amount",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Detail Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow("Receipt No", receiptNo),
                const SizedBox(height: 12),
                if (fatherName.isNotEmpty) ...[
                  _buildDetailRow("Father's Name", fatherName),
                  const SizedBox(height: 12),
                ],
                _buildDetailRow("Payment Mode", paymentMode),
                const SizedBox(height: 12),
                if (months.isNotEmpty) ...[
                  _buildDetailRow("Month", months, isHighlight: true),
                  const SizedBox(height: 12),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "STATUS: ${isPaid ? 'PAID' : 'PARTIAL'}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: isPaid ? Colors.green : Colors.orange,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final String feeId = fee['feeid'] ?? "";
                        final String rDate = fee['date'] ?? "";
                        final String rNo = fee['fee_receipt_no'] ?? "";

                        String urlValue = "";
                        if (_feeSoftware?.toLowerCase() == "quicksw") {
                          urlValue =
                              "https://www.currentdiary.com/feemanage/fee-quicksw-app-api/$_schoolCode/?getcdiaryid=$feeId&getsession=$_session&getfeereceiptno=$rNo&getdatevalue=$rDate";
                        } else {
                          urlValue =
                              "https://www.currentdiary.com/feemanage/fee-quick-app-api/$_schoolCode/?getcdiaryid=$feeId&getsession=$_session&getfeereceiptno=$rNo&getdatevalue=$rDate";
                        }

                        final Uri url = Uri.parse(urlValue);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (mounted) {
                            AppToast.show(
                              context,
                              "Could not open receipt URL",
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: const Text(
                        "VIEW SLIP",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isHighlight
                ? Theme.of(context).primaryColor
                : const Color(0xFF1A1C1E),
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
