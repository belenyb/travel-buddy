part of 'auth_bloc.dart';

enum FormStatus {
  initial,
  pending,
  success,
  error,
}

@immutable
class AuthState {
  final String email;
  final String password;
  final FormStatus status;
  final String? errorMsg;

  const AuthState(
      {this.email = "",
      this.password = "",
      this.status = FormStatus.initial,
      this.errorMsg});

  AuthState copyWith(
          {String? email,
          String? password,
          FormStatus? status,
          String? errorMsg}) =>
      AuthState(
        email: email ?? this.email,
        password: password ?? this.password,
        status: status ?? this.status,
        errorMsg: errorMsg ?? this.errorMsg,
      );
}
