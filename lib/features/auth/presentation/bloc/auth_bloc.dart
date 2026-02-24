import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SubmitSchoolCode>(_onSubmit);
    on<SkipPressed>(_onSkip);
  }

  Future<void> _onSplashStarted(
      SplashStarted event, Emitter<AuthState> emit) async {
    await Future.delayed(const Duration(seconds: 2));
    emit(NavigateToSchoolCode());
  }

  Future<void> _onSubmit(
      SubmitSchoolCode event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthSuccess());
  }

  void _onSkip(SkipPressed event, Emitter<AuthState> emit) {
    emit(AuthSuccess());
  }
}