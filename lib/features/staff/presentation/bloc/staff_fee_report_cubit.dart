import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/staff_repository.dart';
import './staff_fee_report_state.dart';

class StaffFeeReportCubit extends Cubit<StaffFeeReportState> {
  final StaffRepository repository;

  StaffFeeReportCubit({required this.repository}) : super(StaffFeeReportInitial());

  Future<void> fetchFeeReport({
    required String schoolCode,
    required String login,
    required String password,
    required String session,
    required String reportType,
    required String paymentMode,
    required String day,
    required String month,
    required String staffc,
    required String studentFeeSoftware,
  }) async {
    emit(StaffFeeReportLoading());

    final result = await repository.getFeeReport(
      schoolCode: schoolCode,
      login: login,
      password: password,
      session: session,
      reportType: reportType,
      paymentMode: paymentMode,
      day: day,
      month: month,
      staffc: staffc,
      studentFeeSoftware: studentFeeSoftware,
    );

    result.fold(
      (failure) => emit(StaffFeeReportError(failure.message)),
      (report) {
        double total = 0;
        for (var item in report) {
          if (item is Map) {
            total += double.tryParse(item['f-amount']?.toString() ?? '0') ?? 0;
          }
        }
        emit(StaffFeeReportLoaded(report, total));
      },
    );
  }
}
