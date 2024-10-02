import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app_state.dart';
import '../models/favorite_spot_model.dart';

class PlaceController extends GetxController {
  final User? user = AppState.currentUser;

  final Rx<FavoriteSpot?> placeData = Rx<FavoriteSpot?>(null);
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final Rx<String> favoriteId = ''.obs;

  final StreamController<bool> _isFavoriteStreamController =
      StreamController<bool>.broadcast();

  final String apiKey = dotenv.env['FOURSQUARE_API_KEY']!;

  PlaceController() {
    _isFavoriteStreamController.add(false);
  }

  Stream<bool> get isFavoriteStream => _isFavoriteStreamController.stream;

  Future<void> fetchPlaceDetails(String id) async {
    errorMessage.value = '';

    final url = 'https://api.foursquare.com/v3/places/$id';
    final headers = {
      'Authorization': apiKey,
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final FavoriteSpot placeSpot = FavoriteSpot(
            name: jsonResponse["name"] ?? "No name",
            latitude: jsonResponse["geocodes"]["main"]["latitude"] ?? 0,
            longitude: jsonResponse["geocodes"]["main"]["longitude"] ?? 0,
            address: jsonResponse["location"]["address"] ?? "",
            locality: jsonResponse["location"]["locality"] ?? "No locality",
            region: jsonResponse["location"]["region"] ?? "No region",
            country: jsonResponse["location"]["country"],
            category: jsonResponse["categories"][0]["name"] ?? "No category",
            categoryIconPrefix: jsonResponse["categories"][0]["icon"]["prefix"],
            categoryIconSuffix: jsonResponse["categories"][0]["icon"]["suffix"],
            postcode: jsonResponse["location"]["postcode"] ?? "No postcode",
            foursquareId: jsonResponse["fsq_id"]);

        placeData.value = placeSpot;
        checkIfFavorite(placeSpot).then((isFavorite) {
          _isFavoriteStreamController.add(isFavorite);
        });
      } else {
        errorMessage.value = 'Failed to load place details';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkIfFavorite(FavoriteSpot? place) async {
    if (user != null && place != null) {
      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final CollectionReference favoritesCollection = firestore
            .collection('users')
            .doc(user!.uid)
            .collection('favorites');

        final querySnapshot = await favoritesCollection
            .where('name', isEqualTo: place.name)
            .where('latitude', isEqualTo: place.latitude)
            .where('longitude', isEqualTo: place.longitude)
            .where('address', isEqualTo: place.address)
            .where('locality', isEqualTo: place.locality)
            .where('region', isEqualTo: place.region)
            .where('postcode', isEqualTo: place.postcode)
            .where('category', isEqualTo: place.category)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          favoriteId.value = querySnapshot.docs[0].id;
          return true;
        } else {
          return false;
        }
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> removeFromFavorites() async {
    if (user != null && favoriteId.value.isNotEmpty) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference favoritesCollection =
          firestore.collection('users').doc(user!.uid).collection('favorites');

      try {
        await favoritesCollection.doc(favoriteId.value).delete();
        _isFavoriteStreamController.add(false);
        log("Favorite deleted successfully!");
      } catch (error) {
        debugPrint(error.toString());
      }
    } else {
      log("User not logged in or favorite ID unavailable.");
    }
  }

  Future<void> addToFavorites(FavoriteSpot? place) async {
    final FavoriteSpot favoriteSpot = FavoriteSpot(
      name: place?.name ?? "",
      addedAt: DateTime.now(),
      latitude: place?.latitude ?? 0.0,
      longitude: place?.longitude ?? 0.0,
      address: place?.address ?? "",
      locality: place?.locality,
      region: place?.region ?? "",
      postcode: place?.postcode,
      category: place?.category ?? "",
      categoryIconPrefix: place?.categoryIconPrefix ?? "",
      categoryIconSuffix: place?.categoryIconSuffix ?? "",
      country: place?.country ?? "",
      foursquareId: place?.foursquareId ?? "",
    );

    try {
      if (user != null) {
        String userId = user!.uid;
        CollectionReference favoritesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites');

        await favoritesCollection.add(favoriteSpot.toMap());
        _isFavoriteStreamController.add(true);
        log('Favorite spot added successfully!');
      } else {
        log('User not logged in');
      }
    } catch (error) {
      log('Error adding favorite: $error');
    }
  }
}
