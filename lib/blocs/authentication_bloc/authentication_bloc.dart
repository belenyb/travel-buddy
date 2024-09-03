import 'dart:async';
import 'dart:html';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy/auth/firebase_user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<User?> userSubscription;
  AuthenticationBloc({required this.userRepository})
      : super(AuthenticationState.unknown()) {
    on<AuthenticationEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

// This communicates with the backend and emits a state
