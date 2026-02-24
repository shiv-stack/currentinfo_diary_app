import 'package:equatable/equatable.dart';
import '../../data/models/school_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class NavigateToSchoolCode extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final SchoolModel? school;

  AuthSuccess({this.message = "Success", this.school});

  @override
  List<Object?> get props => [message, school];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
