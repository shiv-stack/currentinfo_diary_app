import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../student/data/models/student_model.dart';
import '../../domain/usecases/get_student_record_usecase.dart';

abstract class StudentRecordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentRecordInitial extends StudentRecordState {}

class StudentRecordLoading extends StudentRecordState {}

class StudentRecordLoaded extends StudentRecordState {
  final List<StudentModel> students;
  StudentRecordLoaded(this.students);
  @override
  List<Object?> get props => [students];
}

class StudentRecordError extends StudentRecordState {
  final String message;
  StudentRecordError(this.message);
  @override
  List<Object?> get props => [message];
}

class StudentRecordCubit extends Cubit<StudentRecordState> {
  final GetStudentRecordUseCase getStudentRecordUseCase;

  StudentRecordCubit({required this.getStudentRecordUseCase})
      : super(StudentRecordInitial());

  Future<void> fetchStudentRecord({
    required String schoolCode,
    required String teaname,
    required String tpass,
    required String tclass,
    required String inschool,
    required String session,
    required String classValue,
    required String profession,
    required String section,
    required String transportstatus,
  }) async {
    emit(StudentRecordLoading());

    final result = await getStudentRecordUseCase(
      schoolCode: schoolCode,
      teaname: teaname,
      tpass: tpass,
      tclass: tclass,
      inschool: inschool,
      session: session,
      classValue: classValue,
      profession: profession,
      section: section,
      transportstatus: transportstatus,
    );

    result.fold(
      (failure) => emit(StudentRecordError(failure.message)),
      (students) => emit(StudentRecordLoaded(students)),
    );
  }
}
