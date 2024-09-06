import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/foursquare_bloc/foursquare_bloc.dart';
import '../blocs/foursquare_bloc/foursquare_bloc_event.dart';
import '../blocs/foursquare_bloc/foursquare_bloc_state.dart';
import '../models/foursquare_categories.dart';

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

  void _onMarkerTapped(String markerId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    margin: const EdgeInsets.only(top: 8, bottom: 10),
                    child: const Divider(
                      thickness: 3.5,
                      height: 10,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre del lugar',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Text("Av. Siempre Viva 1234, Buenos Aires"),
                          ],
                        ),
                        Chip(
                          label: Text(
                            "Category",
                            style:
                                Theme.of(context).chipTheme.secondaryLabelStyle,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.clock,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text("18hs - 21hs",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                            Text(
                              "Now open!",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: Colors.green[600]),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap),
                                child: const FaIcon(FontAwesomeIcons.facebookF,
                                    size: 16)),
                            TextButton(
                                onPressed: () {},
                                child: const FaIcon(FontAwesomeIcons.instagram,
                                    size: 16)),
                            TextButton(
                                onPressed: () {},
                                child: const FaIcon(FontAwesomeIcons.xTwitter,
                                    size: 16)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Image.network("https://picsum.photos/200"),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            "Description of the place maybe a bit longer we will add it later",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text("4.5",
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.phone,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text("011 1121 2121"),
                            ],
                          ),
                        ),
                        TextButton(
                            onPressed: () {},
                            child: const Row(children: [
                              FaIcon(FontAwesomeIcons.globe),
                              SizedBox(
                                width: 6,
                              ),
                              Text("website")
                            ])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoursquareBloc, FoursquareBlocState>(
      listener: (context, state) {
        if (state is FoursquareBlocLoadedState) {
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
