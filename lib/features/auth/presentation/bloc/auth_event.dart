import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplashStarted extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class SubmitSchoolCode extends AuthEvent {
  final String code;

  SubmitSchoolCode(this.code);

  @override
  List<Object?> get props => [code];
}

class DisconnectSchool extends AuthEvent {}

class SkipPressed extends AuthEvent {}
