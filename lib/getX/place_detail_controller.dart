import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceController extends GetxController {
  var placeDetails = Rx<PlaceDetails?>(null);
  var placeData = Rx<Map>({});
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  final String apiKey = dotenv.env['FOURSQUARE_API_KEY']!;

  Future<void> fetchPlaceDetails(String id) async {
    isLoading.value = true;
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
        placeData.value = {
          "name": jsonResponse["name"] ?? "No name",
          "address": jsonResponse["location"]["address"] ?? "No address",
          "latitude": jsonResponse["geocodes"]["main"]["latitude"] ?? 0,
          "longitude": jsonResponse["geocodes"]["main"]["longitude"] ?? 0,
          "locality": jsonResponse["location"]["locality"] ?? "No locality",
          "region": jsonResponse["location"]["region"] ?? "No region",
          "category": jsonResponse["categories"][0]["name"] ?? "No category",
          "categoryIcon": {
            "prefix": jsonResponse["categories"][0]["icon"]["prefix"],
            "suffix": jsonResponse["categories"][0]["icon"]["suffix"],
          }
        };
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

PlaceDetails placeDetailsFromJson(String str) =>
    PlaceDetails.fromJson(json.decode(str));

String placeDetailsToJson(PlaceDetails data) => json.encode(data.toJson());

class PlaceDetails {
  final String fsqId;
  final List<Category> categories;
  final List<dynamic> chains;
  final String closedBucket;
  final Geocodes geocodes;
  final String link;
  final Location location;
  final String name;
  final RelatedPlaces relatedPlaces;
  final String timezone;

  PlaceDetails({
    required this.fsqId,
    required this.categories,
    required this.chains,
    required this.closedBucket,
    required this.geocodes,
    required this.link,
    required this.location,
    required this.name,
    required this.relatedPlaces,
    required this.timezone,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) => PlaceDetails(
        fsqId: json["fsq_id"] ?? "",
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"].map((x) => Category.fromJson(x))),
        chains: json["chains"] == null
            ? []
            : List<dynamic>.from(json["chains"].map((x) => x)),
        closedBucket: json["closed_bucket"] ?? "",
        geocodes: json["geocodes"] == null
            ? Geocodes(
                dropOff: DropOff(longitude: 0, latitude: 0),
                main: DropOff(longitude: 0, latitude: 0),
                frontDoor: mockDropOff,
                road: mockDropOff,
                roof: mockDropOff)
            : Geocodes.fromJson(json["geocodes"]),
        link: json["link"] ?? "",
        location: json["location"] == null
            ? Location(
                address: 'address',
                country: 'country',
                crossStreet: 'crossStreet',
                formattedAddress: 'formattedAddress',
                locality: 'locality',
                postcode: 'postcode',
                region: 'region')
            : Location.fromJson(json["location"]),
        name: json["name"] ?? "",
        relatedPlaces: json["related_places"] == null
            ? RelatedPlaces()
            : RelatedPlaces.fromJson(json["related_places"]),
        timezone: json["timezone"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "fsq_id": fsqId,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "chains": List<dynamic>.from(chains.map((x) => x)),
        "closed_bucket": closedBucket,
        "geocodes": geocodes.toJson(),
        "link": link,
        "location": location.toJson(),
        "name": name,
        "related_places": relatedPlaces.toJson(),
        "timezone": timezone,
      };
}

class Category {
  final int id;
  final String name;
  final String shortName;
  final String pluralName;
  final Icon icon;

  Category({
    required this.id,
    required this.name,
    required this.shortName,
    required this.pluralName,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        shortName: json["short_name"],
        pluralName: json["plural_name"],
        icon: Icon.fromJson(json["icon"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_name": shortName,
        "plural_name": pluralName,
        "icon": icon.toJson(),
      };
}

class Icon {
  final String prefix;
  final String suffix;

  Icon({
    required this.prefix,
    required this.suffix,
  });

  factory Icon.fromJson(Map<String, dynamic> json) => Icon(
        prefix: json["prefix"],
        suffix: json["suffix"],
      );

  Map<String, dynamic> toJson() => {
        "prefix": prefix,
        "suffix": suffix,
      };
}

Geocodes geocodesFromJson(String str) => Geocodes.fromJson(json.decode(str));

String geocodesToJson(Geocodes data) => json.encode(data.toJson());

final mockDropOff = DropOff(latitude: 0, longitude: 0);

class Geocodes {
  DropOff? dropOff;
  DropOff? frontDoor;
  DropOff main;
  DropOff? road;
  DropOff? roof;

  Geocodes({
    required this.dropOff,
    required this.frontDoor,
    required this.main,
    required this.road,
    required this.roof,
  });

  factory Geocodes.fromJson(Map<String, dynamic> json) => Geocodes(
        dropOff: json["drop_off"] == null
            ? mockDropOff
            : DropOff.fromJson(json["drop_off"]),
        frontDoor: json["front_door"] == null
            ? mockDropOff
            : DropOff.fromJson(json["front_door"]),
        main:
            json["main"] == null ? mockDropOff : DropOff.fromJson(json["main"]),
        road:
            json["road"] == null ? mockDropOff : DropOff.fromJson(json["road"]),
        roof:
            json["roof"] == null ? mockDropOff : DropOff.fromJson(json["roof"]),
      );

  Map<String, dynamic> toJson() => {
        "drop_off": dropOff?.toJson(),
        "front_door": frontDoor?.toJson(),
        "main": main.toJson(),
        "road": road?.toJson(),
        "roof": roof?.toJson(),
      };
}

class DropOff {
  int latitude;
  int longitude;

  DropOff({
    required this.latitude,
    required this.longitude,
  });

  factory DropOff.fromJson(Map<String, dynamic> json) => DropOff(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

class Location {
  final String address;
  final String country;
  final String crossStreet;
  final String formattedAddress;
  final String locality;
  final String postcode;
  final String region;

  Location({
    required this.address,
    required this.country,
    required this.crossStreet,
    required this.formattedAddress,
    required this.locality,
    required this.postcode,
    required this.region,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        address: json["address"],
        country: json["country"],
        crossStreet: json["cross_street"],
        formattedAddress: json["formatted_address"],
        locality: json["locality"],
        postcode: json["postcode"],
        region: json["region"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "country": country,
        "cross_street": crossStreet,
        "formatted_address": formattedAddress,
        "locality": locality,
        "postcode": postcode,
        "region": region,
      };
}

class RelatedPlaces {
  RelatedPlaces();

  factory RelatedPlaces.fromJson(Map<String, dynamic> json) => RelatedPlaces();

  Map<String, dynamic> toJson() => {};
}
