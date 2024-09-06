import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_state.dart';
import '../auth/firebase_user_repository.dart';
import '../blocs/foursquare_bloc/foursquare_bloc.dart';
import '../widgets/google_map_widget.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/home";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseUserRepository userRepository = FirebaseUserRepository();
    final User? currentUser = AppState.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.travel_explore,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(currentUser!.email!),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await userRepository.signOut();
              Navigator.pushReplacementNamed(context, "/auth");
            },
          ),
        ],
      ),
      body: BlocProvider(
          create: (_) => FoursquareBloc(), child: const GoogleMapWidget()),
    );
  }
}
