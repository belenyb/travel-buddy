import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class FoursquareBlocState {
  const FoursquareBlocState();
}

class FoursquareBlocInitialState extends FoursquareBlocState {}

class FoursquareBlocLoadingState extends FoursquareBlocState {}

class FoursquareBlocLoadedState extends FoursquareBlocState {
  final Set<Marker> markers;

  const FoursquareBlocLoadedState(this.markers);
}

class FoursquareBlocFavoriteMarkedState extends FoursquareBlocState {
  final Marker marker;

  const FoursquareBlocFavoriteMarkedState(this.marker);
}

class FoursquareBlocErrorState extends FoursquareBlocState {
  final String error;

  const FoursquareBlocErrorState(this.error);
}
