import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../auth/firebase_user_repository.dart';
import 'package:http/http.dart' as http;

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
                leading: const Text(
                  "T-Buddy",
                  softWrap: true,
                ),
                title: Text(snapshot.data.email),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_outlined),
                    onPressed: () async {
                      await userRepository.signOut();
                      Navigator.pushReplacementNamed(context, "/auth");
                    },
                  ),
                ],
              ),
              body: Container(
                child: GoogleMapWidget(),
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

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _MyAppState();
}

class _MyAppState extends State<GoogleMapWidget> {
  late GoogleMapController mapController;

  late LatLng _center;
  Set<Marker> _markers = {};
  late String _currentCategory;

  @override
  void initState() {
    super.initState();
    _center = const LatLng(-33.86, 151.20);
    _getUserLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    // Request permission to get the user's location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }
    // Get the current location of the user
    final currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(currentPosition.latitude, currentPosition.longitude);
    });

    // Move the camera to the user's location
    mapController.animateCamera(
      CameraUpdate.newLatLng(_center),
    );
  }

  Future<void> searchPlaces(String category) async {
    _currentCategory = category;
    final String? apiKey = dotenv.env['FOURSQUARE_API_KEY'];
    final response = await http.get(
      Uri.parse(
        'https://api.foursquare.com/v3/places/search?ll=${_center.latitude},${_center.longitude}&categories=$category&radius=6000',
      ),
      headers: {
        'Authorization': apiKey!,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _updateMarkers(data['results']);
    } else {
      log("Failed to load places: ${response.statusCode}");
    }
  }

  void _updateMarkers(List<dynamic> places) {
    Set<Marker> newMarkers = {};

    for (var place in places) {
      final LatLng position = LatLng(
        place['geocodes']['main']['latitude'],
        place['geocodes']['main']['longitude'],
      );
      final String name = place['name'] ?? 'Unnamed Place';

      newMarkers.add(
        Marker(
          markerId: MarkerId(place['fsq_id']),
          position: position,
          infoWindow: InfoWindow(title: name),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _onCameraIdle() async {
    // Get the current camera position
    final LatLngBounds visibleRegion = await mapController.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );

    setState(() {
      _center = centerLatLng;
    });

    searchPlaces(_currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              onCameraIdle: _onCameraIdle,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            height: 45.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces("10000"),
                    child: const Text("Arts and Entertainment"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces("13000"),
                    child: const Text("Dining and Drinking"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces("14000"),
                    child: const Text("Events"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces("19009"),
                    child: const Text("Hotels and Accommodation"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces("10027"),
                    child: const Text("Museums"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces("16000"),
                    child: const Text("Landmarks"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces("18000"),
                    child: const Text("Sports and Recreation"),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => searchPlaces("17000"),
                    child: const Text("Stores"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
