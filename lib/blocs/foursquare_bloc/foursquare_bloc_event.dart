import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class FoursquareBlocEvent {
  const FoursquareBlocEvent();
}

class SearchPlacesEvent extends FoursquareBlocEvent {
  final String category;
  final LatLng center;

  const SearchPlacesEvent(this.category, this.center);
}

class AddFavoriteMarkerEvent extends FoursquareBlocEvent {
  final String markerId;
  final LatLng position;
  final String title;

  AddFavoriteMarkerEvent(this.markerId, this.position, this.title);
}
