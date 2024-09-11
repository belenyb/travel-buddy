import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteSpot {
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

  FavoriteSpot({
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
  });

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
      "categoryIconPrefix": categoryIconPrefix,
      "categoryIconSuffix": categoryIconSuffix,
    };
  }

  // Create a FavoriteSpot object from Firestore map
  factory FavoriteSpot.fromMap(Map<String, dynamic> map) {
    return FavoriteSpot(
      name: map['name'] ?? "No name",
      addedAt: (map['addedAt'] as Timestamp?)?.toDate(),
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'] ?? "No address",
      locality: map['locality'],
      region: map['region'] ?? "No region",
      country: map['country'] ?? "No country",
      postcode: map['postcode'],
      category: map['category'] ?? "No category",
      categoryIconPrefix: map['categoryIconPrefix'] ?? "",
      categoryIconSuffix: map['categoryIconSuffix'] ?? "",
    );
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
