import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteSpot {
  final String? id;
  final String name;
  final DateTime? addedAt;
  final double latitude;
  final double longitude;
  final String address;
  final String? locality;
  final String region;
  final String country;
  final String? postcode;
  final String category;
  final String categoryIconPrefix;
  final String categoryIconSuffix;
  final String foursquareId;

  FavoriteSpot({
    this.id = "",
    required this.name,
    this.addedAt,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.locality,
    required this.region,
    required this.country,
    this.postcode,
    required this.category,
    required this.categoryIconPrefix,
    required this.categoryIconSuffix,
    required this.foursquareId,
  });

  // Convert Firestore document data to a FavoriteSpot object, including the document ID
  factory FavoriteSpot.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FavoriteSpot.fromMap(doc.id, data);  // Pass doc.id as the id
  }

  // Convert Firestore map to FavoriteSpot object, with an id parameter
  factory FavoriteSpot.fromMap(String id, Map<String, dynamic> map) {
    return FavoriteSpot(
      id: id,
      name: map['name'] ?? "No name",
      addedAt: (map['addedAt'] as Timestamp?)?.toDate(),
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'] ?? "",
      locality: map['locality'],
      region: map['region'] ?? "No region",
      country: map['country'] ?? "No country",
      postcode: map['postcode'],
      category: map['category'] ?? "No category",
      categoryIconPrefix: map['categoryIconPrefix'] ?? "",
      categoryIconSuffix: map['categoryIconSuffix'] ?? "",
      foursquareId: map["foursquareId"] ?? ""
    );
  }

  // Convert FavoriteSpot object to a Map to store in Firestore (excluding the id field)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'addedAt': addedAt ?? DateTime.now(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'locality': locality ?? "",
      'region': region,
      'country': country,
      'postcode': postcode ?? "",
      'category': category,
      'categoryIconPrefix': categoryIconPrefix,
      'categoryIconSuffix': categoryIconSuffix,
      'foursquareId': foursquareId,
    };
  }
}

CategoryIcon categoryIconFromJson(String str) =>
    CategoryIcon.fromJson(json.decode(str));

String categoryIconToJson(CategoryIcon data) => json.encode(data.toJson());

class CategoryIcon {
  String prefix;
  String suffix;

  CategoryIcon({
    required this.prefix,
    required this.suffix,
  });

  factory CategoryIcon.fromJson(Map<String, dynamic> json) => CategoryIcon(
        prefix: json["prefix"] ?? "",
        suffix: json["suffix"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "prefix": prefix,
        "suffix": suffix,
      };
}
