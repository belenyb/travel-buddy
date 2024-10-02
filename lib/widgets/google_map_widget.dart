import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/foursquare_bloc/foursquare_bloc.dart';
import '../blocs/foursquare_bloc/foursquare_bloc_event.dart';
import '../blocs/foursquare_bloc/foursquare_bloc_state.dart';
import '../models/foursquare_categories.dart';
import '../singleton/favorites_service.dart';
import 'place_details_sheet.dart';

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
  late MapType _mapType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _center = const LatLng(-33.86, 151.20);
    _currentCategory = "";
    _mapType = MapType.normal;
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

  void _onSearchCategory(String category) async {
    _currentCategory = category;
    if (category == "1") {
      // Favorites
      final favorites = await favoritesService.fetchFavoritesList();
      _markers = {};
      for (var favorite in favorites) {
        _markers.add(
          Marker(
            markerId: MarkerId(favorite.id!),
            position: LatLng(favorite.latitude, favorite.longitude),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            consumeTapEvents: true,
            onTap: () {
              _onMarkerTapped(favorite.foursquareId);
            },
          ),
        );
      }
      final Marker firstMarker = _markers.first;
      mapController.animateCamera(
        CameraUpdate.newLatLng(firstMarker.position),
      );
      _isLoading = false;
      setState(() {});
      return;
    } else {
      final placesBloc = BlocProvider.of<FoursquareBloc>(context);
      placesBloc.add(SearchPlacesEvent(category, _center));
    }
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

    if (_currentCategory != "" && _currentCategory != "1")
      _onSearchCategory(_currentCategory);
  }

  void _onMarkerTapped(String foursquareId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return PlaceDetailsSheet(foursquareId: foursquareId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoursquareBloc, FoursquareBlocState>(
      listener: (context, state) {
        if (state is FoursquareBlocFavoriteMarkedState) {
          final Marker marker = Marker(
            markerId: state.marker.markerId,
            position: state.marker.position,
            consumeTapEvents: true,
            onTap: () {
              _onMarkerTapped(state.marker.markerId.value);
            },
          );
          _markers = {marker};
          setState(() {
            _isLoading = false;
          });
          mapController.animateCamera(
            CameraUpdate.newLatLng(_markers.first.position),
          );
        }
        if (state is FoursquareBlocLoadedState) {
          _markers = {};
          setState(() {
            _markers = state.markers.map((marker) {
              return Marker(
                markerId: marker.markerId,
                position: marker.position,
                consumeTapEvents: true,
                onTap: () {
                  _onMarkerTapped(marker.markerId.value);
                },
              );
            }).toSet();
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
              mapType: _mapType,
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
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
              child: Row(
                children: [
                  Container(
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
                              border: Border.all(
                                  width: 0.5, color: Colors.black26)),
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
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.rectangle),
                    child: IconButton(
                      onPressed: () {
                        _mapType = _mapType == MapType.normal
                            ? MapType.satellite
                            : MapType.normal;
                        setState(() {});
                      },
                      icon: const Icon(Icons.satellite_alt),
                    ),
                  ),
                ],
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
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor:
              isActive ? Theme.of(context).primaryColor : Colors.black45,
          side: BorderSide(
              color: isActive ? Theme.of(context).primaryColor : Colors.black26,
              width: isActive ? 1 : 0.5),
        ),
        onPressed: () => _onSearchCategory(category),
        child: Text(label),
      ),
    );
  }
}
