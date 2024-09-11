import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/favorite_spot_model.dart';

class PlaceController extends GetxController {
  final Rx<FavoriteSpot?> placeData = Rx<FavoriteSpot?>(null);
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  final String apiKey = dotenv.env['FOURSQUARE_API_KEY']!;

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
          address: jsonResponse["location"]["address"] ?? "No address",
          locality: jsonResponse["location"]["locality"] ?? "No locality",
          region: jsonResponse["location"]["region"] ?? "No region",
          country: jsonResponse["location"]["country"],
          category: jsonResponse["categories"][0]["name"] ?? "No category",
          categoryIconPrefix: jsonResponse["categories"][0]["icon"]["prefix"],
          categoryIconSuffix: jsonResponse["categories"][0]["icon"]["suffix"],
          postcode: jsonResponse["location"]["postcode"] ?? "No postcode",
        );

        placeData.value = placeSpot;
      } else {
        errorMessage.value = 'Failed to load place details';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
