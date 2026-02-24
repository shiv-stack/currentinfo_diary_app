abstract class AuthEvent {}

class SplashStarted extends AuthEvent {}

class SubmitSchoolCode extends AuthEvent {
  final String code;

  SubmitSchoolCode(this.code);
}

class SkipPressed extends AuthEvent {}
