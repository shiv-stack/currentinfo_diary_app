import 'package:flutter/foundation.dart';

class FeeReportModel {
  final String paidOn;
  final String name;
  final String receiptNo;
  final String paymentMode;
  final String amount;
  final String dues;
  final String month;
  final String paidFor;
  final String admissionNo;
  final String contact;

  FeeReportModel({
    required this.paidOn,
    required this.name,
    required this.receiptNo,
    required this.paymentMode,
    required this.amount,
    required this.dues,
    required this.month,
    required this.paidFor,
    required this.admissionNo,
    required this.contact,
  });

  factory FeeReportModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('--- FeeReportModel.fromJson Raw Data ---');
      json.forEach((key, value) => print('  $key: $value'));
    }

    return FeeReportModel(
      paidOn: json['date']?.toString() ?? 'N/A',
      name: json['name']?.toString() ?? 'N/A',
      receiptNo: json['fee_receipt_no']?.toString() ?? 'N/A',
      paymentMode: json['payment-mode']?.toString() ?? 'N/A',
      amount: json['f-amount']?.toString() ?? '0',
      dues: json['dues']?.toString() ?? '0',
      month: json['month']?.toString() ?? 'N/A',
      paidFor: json['f-m-submitted']?.toString() ?? 'N/A',
      admissionNo: json['admissionno']?.toString() ?? 'N/A',
      contact: json['mobile']?.toString() ?? json['contact']?.toString() ?? 'N/A',
    );
  }

  @override
  String toString() {
    return 'FeeReportModel(name: $name, amount: $amount, month: $month)';
  }
}
