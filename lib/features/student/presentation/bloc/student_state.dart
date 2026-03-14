import 'package:equatable/equatable.dart';
import '../../data/models/student_model.dart';

abstract class StudentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoginSuccess extends StudentState {
  final StudentModel student;

  StudentLoginSuccess(this.student);

  @override
  List<Object?> get props => [student];
}

class StudentLoginFailure extends StudentState {
  final String message;

  StudentLoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
