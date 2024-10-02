import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final StreamController<Map<String, List<FavoriteSpot>>> _favoritesController =
      StreamController<Map<String, List<FavoriteSpot>>>.broadcast();
  Stream<Map<String, List<FavoriteSpot>>> get favoritesStream =>
      _favoritesController.stream;

  final User? user = AppState.currentUser;

  Future<List<FavoriteSpot>> fetchFavoritesStream() async {
    List<FavoriteSpot> favoritesList = [];
    Map<String, List<FavoriteSpot>> groupedFavorites = {};
    if (user != null) {
      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final CollectionReference favoritesCollection = firestore
            .collection('users')
            .doc(user!.uid)
            .collection('favorites');
        favoritesCollection.snapshots().listen((snapshot) {
          favoritesList = snapshot.docs
              .map((doc) => FavoriteSpot.fromFirestore(doc))
              .toList();
          for (var favoriteSpot in favoritesList) {
            if (!groupedFavorites.containsKey(favoriteSpot.category)) {
              groupedFavorites[favoriteSpot.category] = [];
            }
            groupedFavorites[favoriteSpot.category]!.add(favoriteSpot);
          }
          _favoritesController.add(groupedFavorites);
        });
      } catch (error) {
        // ignore: avoid_print
        print('Error fetching favorites: $error');
        _favoritesController.addError(error);
      }
    }
    return favoritesList;
  }

  Future<List<FavoriteSpot>> fetchFavoritesList() async {
    List<FavoriteSpot> favorites = [];

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference favoritesCollection =
          firestore.collection('users').doc(user!.uid).collection('favorites');
      final querySnapshot = await favoritesCollection.get();
      favorites = querySnapshot.docs
          .map((doc) => FavoriteSpot.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Error in fetchFavoritesList(): ${e.toString()}");
    }
    return favorites;
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
