import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff.dart';
import '../bloc/staff_fee_report_cubit.dart';
import '../bloc/staff_fee_report_state.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

class StaffFeeReportPage extends StatefulWidget {
  final Staff staff;
  const StaffFeeReportPage({super.key, required this.staff});

  @override
  State<StaffFeeReportPage> createState() => _StaffFeeReportPageState();
}

class _StaffFeeReportPageState extends State<StaffFeeReportPage> {
  final List<String> reportTypes = ["Fee's Collection", "Fees Defaulters"];
  final List<String> paymentModes = [
    "Cash/Cheque...",
    "CASH",
    "UPI",
    "Card Swap",
    "Mobile App",
    "Cheque",
    "Online",
    "Paytm",
    "POS",
    "Smart Hub",
    "ECMS"
  ];
  final List<String> days = List.generate(31, (i) => (i + 1).toString());
  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  final List<String> sessions = ["2026-2027", "2025-2026", "2024-2025"];

  String selectedReportType = "Fee's Collection";
  String selectedPaymentMode = "Cash/Cheque...";
  String selectedDay = "25";
  String selectedMonth = "April";
  String selectedSession = "2026-2027";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<StaffFeeReportCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            "Admin - Fee Report SW",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF1A1C1E),
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1C1E),
          elevation: 0,
          centerTitle: false,
        ),
        body: BlocBuilder<StaffFeeReportCubit, StaffFeeReportState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // --- Premium Filter Section (Matching User Records) ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              "Report Type",
                              reportTypes,
                              selectedReportType,
                              (val) => setState(() => selectedReportType = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              "Payment Mode",
                              paymentModes,
                              selectedPaymentMode,
                              (val) => setState(() => selectedPaymentMode = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildDropdown(
                              "Day",
                              days,
                              selectedDay,
                              (val) => setState(() => selectedDay = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildDropdown(
                              "Month",
                              months,
                              selectedMonth,
                              (val) => setState(() => selectedMonth = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: _buildDropdown(
                              "Session",
                              sessions,
                              selectedSession,
                              (val) => setState(() => selectedSession = val!),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: state is StaffFeeReportLoading
                              ? null
                              : () => _onSearchPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: state is StaffFeeReportLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      "SEARCH RECORDS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- Results Section ---
                if (state is StaffFeeReportLoaded)
                  state.report.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Text(
                              "No matching records found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Total Amount: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "₹${state.totalAmount.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.report.length,
                              itemBuilder: (context, index) {
                                return _buildUserRecordStyleCard(state.report[index]);
                              },
                            ),
                          ],
                        )
                else if (state is StaffFeeReportError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Text(
                        "Enter filters and tap Search.",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.expand_more_rounded, size: 20),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRecordStyleCard(dynamic item) {
    final String name = item['name']?.toString() ?? "Student Name";
    final String admissionNo = item['admissionno']?.toString() ?? "N/A";
    final String amount = item['f-amount']?.toString() ?? "0";
    final String receipt = item['fee_receipt_no']?.toString() ?? "N/A";
    final String mode = item['payment-mode']?.toString() ?? "N/A";
    final String dues = item['dues']?.toString() ?? "0";
    final String month = item['month']?.toString() ?? "N/A";
    final String paidFor = item['f-m-submitted']?.toString() ?? "N/A";
    final String paidOn = item['date']?.toString() ?? "N/A";
    final String contact = item['mobile']?.toString() ?? item['contact']?.toString() ?? "N/A";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      Text(
                        "Admission No: $admissionNo",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "₹$amount",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 12, endIndent: 12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _compactInfo(Icons.calendar_today_outlined, "Month: $month")),
                    Expanded(child: _compactInfo(Icons.check_circle_outline_rounded, "Paid For: $paidFor")),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _compactInfo(Icons.event_note_outlined, "Session: $selectedSession")),
                    Text(
                      "Status: SUCCESS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.green.shade600,
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

  Widget _cardInfoRow(IconData icon1, String label1, IconData icon2, String label2) {
    return Row(
      children: [
        Expanded(child: _compactInfo(icon1, label1)),
        Expanded(child: _compactInfo(icon2, label2)),
      ],
    );
  }

  Widget _compactInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF495057),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _onSearchPressed(BuildContext context) async {
    final monthMap = {
      "January": "01", "February": "02", "March": "03", "April": "04", "May": "05", "June": "06",
      "July": "07", "August": "08", "September": "09", "October": "10", "November": "11", "December": "12"
    };
    final authLocal = di.sl<AuthLocalDataSource>();
    final feeSoftware = await authLocal.getCachedFeeSoftware() ?? "quickfeesw";

    // Format parameters to match Postman exactly
    final String apiDay = selectedDay.padLeft(2, '0');
    final String apiMonth = monthMap[selectedMonth] ?? "01";
    final String apiPaymentMode = selectedPaymentMode == "Cash/Cheque..." ? "" : selectedPaymentMode;
    
    String staffc = widget.staff.assignClass ?? widget.staff.designation ?? "Admin";
    if (staffc.toLowerCase().contains("admin")) staffc = "Admin";

    if (context.mounted) {
      context.read<StaffFeeReportCubit>().fetchFeeReport(
        schoolCode: widget.staff.schoolCode ?? "",
        login: widget.staff.name ?? "",
        password: widget.staff.password ?? "",
        session: selectedSession,
        reportType: selectedReportType,
        paymentMode: apiPaymentMode,
        day: apiDay,
        month: apiMonth,
        staffc: staffc,
        studentFeeSoftware: feeSoftware,
      );
    }
  }
}
