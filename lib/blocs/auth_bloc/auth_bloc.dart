import 'dart:developer';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
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
    emit(state.copyWith(status: FormStatus.initial));
    emit(state.copyWith(email: event.email));
  }

  void passwordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(status: FormStatus.initial));
    emit(state.copyWith(password: event.password));
  }

  void signIn(SignIn event, Emitter<AuthState> emit) async {
    final email = state.email;
    final password = state.password;

    emit(state.copyWith(status: FormStatus.pending));

    if (email.isEmpty || password.isEmpty) {
      emit(state.copyWith(status: FormStatus.error));
      return;
    }

    try {
      await firebaseUserRepository.signIn(email, password);
      emit(state.copyWith(status: FormStatus.success));
    } on Exception catch (e) {
      log(e.toString());
      emit(state.copyWith(status: FormStatus.error, errorMsg: e.toString()));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(status: FormStatus.error, errorMsg: e.toString()));
    }
  }

  void signUp(SignUp event, Emitter<AuthState> emit) async {
    final email = state.email;
    final password = state.password;

    emit(state.copyWith(status: FormStatus.pending));

    if (email.isEmpty || password.isEmpty) {
      emit(state.copyWith(status: FormStatus.error));
      return;
    }

    try {
      final User? user = await firebaseUserRepository.signUp(email, password);
      if (user != null) {
        emit(state.copyWith(status: FormStatus.success));
      } else {
        emit(state.copyWith(
            status: FormStatus.error, errorMsg: "Error signing up"));
      }
    } catch (e) {
      emit(state.copyWith(status: FormStatus.error, errorMsg: e.toString()));
    }
  }
}
