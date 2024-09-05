import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../app_state.dart';
import '../auth/firebase_user_repository.dart';
import '../blocs/foursquare_bloc/foursquare_bloc.dart';
import '../blocs/foursquare_bloc/foursquare_bloc_event.dart';
import '../blocs/foursquare_bloc/foursquare_bloc_state.dart';
import '../models/foursquare_categories.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/home";
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseUserRepository userRepository = FirebaseUserRepository();
    final User? currentUser = AppState.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.travel_explore,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(currentUser!.email!),
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
      body: BlocProvider(
          create: (_) => FoursquareBloc(), child: const GoogleMapWidget()),
    );
  }
}

//

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _center = const LatLng(-33.86, 151.20);
    _currentCategory = "";
    _getUserLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(
      CameraUpdate.newLatLng(_center),
    );
  }

  _getUserLocation() async {
    final currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(currentPosition.latitude, currentPosition.longitude);
    });
  }

  void _onSearchCategory(String category) {
    _currentCategory = category;
    final placesBloc = BlocProvider.of<FoursquareBloc>(context);
    placesBloc.add(SearchPlacesEvent(category, _center));
  }

  void _onCameraIdle() async {
    final LatLngBounds visibleRegion = await mapController.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );

    setState(() {
      _center = centerLatLng;
    });

    if (_currentCategory != "") _onSearchCategory(_currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoursquareBloc, FoursquareBlocState>(
      listener: (context, state) {
        if (state is FoursquareBlocLoadedState) {
          setState(() {
            _markers = state.markers;
            _isLoading = false;
          });
        } else if (state is FoursquareBlocErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
          setState(() {
            _isLoading = false;
          });
        } else if (state is FoursquareBlocLoadingState) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
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
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              height: 45.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: FoursquareCategories.values.length,
                itemBuilder: (BuildContext context, int index) {
                  final category = FoursquareCategories.values[index];
                  return _categoryButton(category.id, category.name);
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        mapController.animateCamera(CameraUpdate.zoomOut());
                      },
                      icon: const Icon(
                        Icons.remove,
                        size: 28,
                      ),
                    ),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 0.5, color: Colors.black26)),
                    ),
                    IconButton(
                      onPressed: () {
                        mapController.animateCamera(CameraUpdate.zoomIn());
                      },
                      icon: const Icon(Icons.add, size: 28),
                    ),
                  ],
                ),
              ),
            ),
            _isLoading
                ? const LinearProgressIndicator()
                : const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _categoryButton(String category, String label) {
    final isActive = _currentCategory == category;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor:
              isActive ? Theme.of(context).primaryColor : Colors.black45,
        ),
        onPressed: () => _onSearchCategory(category),
        child: Text(label),
      ),
    );
  }
}
