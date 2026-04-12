import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/staff_login_usecase.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffLoginUseCase staffLoginUseCase;

  StaffBloc({required this.staffLoginUseCase}) : super(StaffInitial()) {
    on<StaffLoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    StaffLoginSubmitted event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());

    final result = await staffLoginUseCase(
      schoolCode: event.schoolCode,
      name: event.name,
      uniqueCode: event.uniqueCode,
    );

    result.fold(
      (failure) => emit(StaffLoginFailure(failure.message)),
      (staff) => emit(StaffLoginSuccess(staff)),
    );
  }
}
