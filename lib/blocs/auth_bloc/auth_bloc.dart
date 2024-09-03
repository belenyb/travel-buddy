import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/auth/firebase_user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<EmailChanged>(emailChanged);
    on<PasswordChanged>(passwordChanged);
    on<SignIn>(signIn);
    on<SignUp>(signUp);
  }

  final FirebaseUserRepository firebaseUserRepository =
      FirebaseUserRepository();

  void emailChanged(EmailChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(email: event.email));
  }

  void passwordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(password: event.password));
  }

  void signIn(SignIn event, Emitter<AuthState> emit) async {
    final email = state.email;
    final password = state.password;

    if (email.isEmpty || password.isEmpty) return;
    await firebaseUserRepository.signIn(email, password);
  }

  void signUp(SignUp event, Emitter<AuthState> emit) async {
    final email = state.email;
    final password = state.password;

    if (email.isEmpty || password.isEmpty) return;

    emit(state.copyWith(status: FormStatus.pending));

    final User? user = await firebaseUserRepository.signUp(email, password);

    if (user != null) {
      emit(state.copyWith(status: FormStatus.success));
    } else {
      emit(state.copyWith(status: FormStatus.error));
    }
  }
}
