part of 'auth_bloc.dart';

class AuthEvent {
  const AuthEvent();
}

class EmailChanged extends AuthEvent {
  final String email;
  EmailChanged(this.email);
}

class PasswordChanged extends AuthEvent {
  final String password;
  PasswordChanged(this.password);
}

class SignIn extends AuthEvent {
  SignIn();
}

class SignUp extends AuthEvent {
  SignUp();
}
