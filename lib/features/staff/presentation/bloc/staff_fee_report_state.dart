import '../../data/models/fee_report_model.dart';
import 'package:equatable/equatable.dart';

abstract class StaffFeeReportState extends Equatable {
  const StaffFeeReportState();

  @override
  List<Object?> get props => [];
}

class StaffFeeReportInitial extends StaffFeeReportState {}

class StaffFeeReportLoading extends StaffFeeReportState {}

class StaffFeeReportLoaded extends StaffFeeReportState {
  final List<FeeReportModel> report;
  final double totalAmount;
  final int timestamp;
  const StaffFeeReportLoaded(this.report, this.totalAmount, this.timestamp);

  @override
  List<Object?> get props => [report, totalAmount, timestamp];
}

class StaffFeeReportError extends StaffFeeReportState {
  final String message;
  const StaffFeeReportError(this.message);

  @override
  List<Object?> get props => [message];
}
