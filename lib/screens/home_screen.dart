import 'package:flutter/material.dart';
import '../auth/firebase_user_repository.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/home";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseUserRepository userRepository = FirebaseUserRepository();
    return FutureBuilder(
      future: userRepository.getCurrentUser(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Text("User not logged in");
          } else {
            return Scaffold(
              appBar: AppBar(
                leading: Text("T-Buddy"),
                title: Text(snapshot.data.email),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_outlined),
                    onPressed: () async {
                      await userRepository.signOut();
                      Navigator.pushReplacementNamed(context, "/");
                    },
                  ),
                ],
              ),
              body: Container(
                child: Text("Welcome user"),
              ),
            );
          }
        } else {
          return Container();
        }
      },
    );
  }
}
