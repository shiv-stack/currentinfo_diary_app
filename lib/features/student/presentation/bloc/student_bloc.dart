import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/student_login_usecase.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentLoginUseCase studentLoginUseCase;

  StudentBloc({required this.studentLoginUseCase}) : super(StudentInitial()) {
    on<StudentLoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    StudentLoginSubmitted event,
    Emitter<StudentState> emit,
  ) async {
    emit(StudentLoading());

    final result = await studentLoginUseCase(
      schoolCode: event.schoolCode,
      name: event.name,
      uniqueCode: event.uniqueCode,
    );

    result.fold(
      (failure) => emit(StudentLoginFailure(failure.message)),
      (student) => emit(StudentLoginSuccess(student)),
    );
  }
}
