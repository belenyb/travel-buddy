part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

// This catches events like a click on a button

class AuthenticationUserChanged extends AuthenticationEvent {
  final User? user;
  const AuthenticationUserChanged(this.user);
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}
