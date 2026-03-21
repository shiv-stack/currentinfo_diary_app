import 'package:equatable/equatable.dart';

class LeaveModel extends Equatable {
  final dynamic id;
  final String? fromDate;
  final String? toDate;
  final String? reason;
  final String? status;
  final String? requestDate;
  final String? teacherName;
  final String? teacherClass;

  const LeaveModel({
    this.id,
    this.fromDate,
    this.toDate,
    this.reason,
    this.status,
    this.requestDate,
    this.teacherName,
    this.teacherClass,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['leaveid'],
      fromDate: json['fromdate'] as String?,
      toDate: json['todate'] as String?,
      reason: json['reasonsforleave'] as String?,
      status: json['approverejectstatus'] as String?,
      requestDate: json['todaydatetime'] as String?,
      teacherName: json['teachername'] as String?,
      teacherClass: json['teacherclass'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fromDate,
    toDate,
    reason,
    status,
    requestDate,
    teacherName,
    teacherClass,
  ];
}
