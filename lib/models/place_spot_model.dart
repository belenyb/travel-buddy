import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceSpot {
  final String name;
  final DateTime addedAt;
  final int latitude;
  final int longitude;
  final String address;
  final String? locality;
  final String region;
  final String postcode;
  final String category;
  final Map categoryIcon;

  PlaceSpot({
    required this.name,
    required this.addedAt,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.locality,
    required this.region,
    required this.postcode,
    required this.category,
    required this.categoryIcon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'addedAt': addedAt,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'locality': locality,
      'region': region,
      'postcode': postcode,
      'category': category,
      'categoryIcon': categoryIcon,
    };
  }

  // Create a FavoriteSpot object from Firestore map
  factory PlaceSpot.fromMap(Map<String, dynamic> map) {
    return PlaceSpot(
      name: map['name'],
      addedAt: (map['addedAt'] as Timestamp).toDate(),
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      locality: map['locality'],
      region: map['region'],
      postcode: map['postcode'],
      category: map['category'],
      categoryIcon: {},
    );
  }
}
