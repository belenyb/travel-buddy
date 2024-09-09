import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_buddy/app_state.dart';

class FirebaseUserRepository implements UserRepository {
  // The FirebaseUserRepository class implements the interface methods using Firebase Authentication functionalities
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final usersCollection = FirebaseFirestore.instance.collection("users");

  // Future es como una foto de la data, como abrir y cerrar el grifo
  // Stream es como dejar la canilla abierta y cada vez que sale un nuevo tipo de agua te llega una notificacion
  // La notificacion sera si esta autenticado o no
  @override
  Stream<User?> get user {
    return firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser;
      return user;
    });
  }

  @override
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential credentials = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = credentials.user;
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception(e.message ?? "The password is too weak");
      } else if (e.code == 'email-already-in-use') {
        throw Exception(e.message ?? "The email is already in use");
      } else if (e.code == "invalid-email") {
        throw Exception(e.message ?? "The email is invalid");
      }
      rethrow;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      await getCurrentUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        log('Invalid user credentials.');
      }
      throw Exception(e.message ?? "Error signing in");
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
      AppState.isAuthenticated = false;
      AppState.currentUser = null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      AppState.currentUser = currentUser;
      return currentUser;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // @override
  // Future<UserModel> getMyUser(String userId) async {
  //   try {
  //     return usersCollection
  //         .doc(userId)
  //         .get()
  //         .then((value) => jsonDecode(value.data()));
  //   } catch (e) {
  //     log(e.toString());
  //     rethrow;
  //   }
  // }

  // @override
  // Future<void> setUserData(UserModel user) async {
  //   try {
  //     await usersCollection.doc(user.id).set(user.toMap(user));
  //   } catch (e) {
  //     log(e.toString());
  //     rethrow;
  //   }
  // }
}

abstract class UserRepository {
  // This interface allows for implementing different user repositories based
  // on different user authentication systems (Firebase, local storage, etc.).
  Stream<User?> get user;

  Future<void> signIn(String email, String password);
  Future<User?> signUp(String user, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  // FutureOr<User?> getCurrentUser();
  // FutureOr<void> setUserData(UserModel user);
  // FutureOr<UserModel> getMyUser(String userId);
}
