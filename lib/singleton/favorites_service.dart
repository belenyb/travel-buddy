import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_state.dart';
import '../models/favorite_spot_model.dart';

class _FavoritesService {
  _FavoritesService._privateConstructor();
  static final _FavoritesService _instance =
      _FavoritesService._privateConstructor();

  // Getter to access the instance
  factory _FavoritesService() {
    return _instance;
  }

  // Stream
  final StreamController<List<FavoriteSpot>> _favoritesController =
      StreamController<List<FavoriteSpot>>.broadcast();
  Stream<List<FavoriteSpot>> get favoritesStream => _favoritesController.stream;

  final User? user = AppState.currentUser;

  Future<List<FavoriteSpot>> fetchFavorites() async {
    List<FavoriteSpot> favoritesList = <FavoriteSpot>[];
    if (user != null) {
      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final CollectionReference favoritesCollection = firestore
            .collection('users')
            .doc(user!.uid)
            .collection('favorites');
        favoritesCollection.snapshots().listen((snapshot) {
          List<FavoriteSpot> favoritesList = snapshot.docs
              .map((doc) => FavoriteSpot.fromFirestore(doc))
              .toList();
          _favoritesController.add(favoritesList);
        });
        return [];
      } catch (error) {
        // ignore: avoid_print
        print('Error fetching favorites: $error');
        _favoritesController.addError(error);
      }
    }
    return favoritesList;
  }

  Future<void> deleteFavorite(String favoriteId) async {
    if (user != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference favoritesCollection =
          firestore.collection('users').doc(user!.uid).collection('favorites');
      await favoritesCollection.doc(favoriteId).delete();
    }
  }

  void dispose() {
    _favoritesController.close();
  }
}

final favoritesService = _FavoritesService();
