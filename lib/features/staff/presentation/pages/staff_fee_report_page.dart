import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff.dart';
import '../bloc/staff_fee_report_cubit.dart';
import '../bloc/staff_fee_report_state.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../core/constants/app_urls.dart';

import 'package:flutter/foundation.dart';
import '../../data/models/fee_report_model.dart';

class StaffFeeReportPage extends StatefulWidget {
  final Staff staff;
  const StaffFeeReportPage({super.key, required this.staff});

  @override
  State<StaffFeeReportPage> createState() => _StaffFeeReportPageState();
}

class _StaffFeeReportPageState extends State<StaffFeeReportPage> {
// ... existing state fields ...
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

  Widget _buildUserRecordStyleCard(FeeReportModel item) {
    if (kDebugMode) {
      print('Before Rendering - Name: ${item.name}, Month: ${item.month}, Amount: ${item.amount}');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar with Paid On
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Paid On ",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  item.paidOn,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Rs ${item.amount}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                Text(
                  "Receipt No ${item.receiptNo}, Payment Mode ${item.paymentMode}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Amount Rs ${item.amount}, Dues ${item.dues}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Month : ${item.month}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Paid For : ${item.paidFor}",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                Text(
                  "Admission No : ${item.admissionNo}",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Status: SUCCESS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.green.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // View Slip placeholder
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("VIEW SLIP", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
    String feeSoftware = await authLocal.getCachedFeeSoftware() ?? "quickfeesw";
    
    // Normalize "quicksw" to "quickfeesw" to match Postman exactly
    if (feeSoftware.toLowerCase() == "quicksw") {
      feeSoftware = "quickfeesw";
    }

    // Format parameters to match Postman exactly
    final String apiDay = selectedDay.padLeft(2, '0');
    final String apiMonth = monthMap[selectedMonth] ?? "01";
    final String apiPaymentMode = selectedPaymentMode == "Cash/Cheque..." ? "" : selectedPaymentMode;
    
    String staffc = widget.staff.assignClass ?? widget.staff.designation ?? "Admin";
    if (staffc.toLowerCase().contains("admin")) staffc = "Admin";

    if (kDebugMode) {
      print('--- SENDING FEE REPORT REQUEST ---');
      print('URL: ${AppUrls.getFees(widget.staff.schoolCode ?? "")}');
      print('Login: ${widget.staff.name}');
      print('Password: ${widget.staff.password}');
      print('StaffC: $staffc');
      print('Day/Date: $apiDay');
      print('Month: $apiMonth');
      print('Session: $selectedSession');
      print('PaymentMode: $apiPaymentMode');
      print('FeeSoftware: $feeSoftware');
    }

    if (context.mounted) {
      context.read<StaffFeeReportCubit>().fetchFeeReport(
        schoolCode: widget.staff.schoolCode ?? "",
        login: widget.staff.name ?? "", // Match Postman login field
        password: widget.staff.password ?? "", // Match Postman password field
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
