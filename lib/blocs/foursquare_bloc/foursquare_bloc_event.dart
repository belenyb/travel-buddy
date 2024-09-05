import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class FoursquareBlocEvent extends Equatable {
  const FoursquareBlocEvent();

  @override
  List<Object> get props => [];
}

class SearchPlacesEvent extends FoursquareBlocEvent {
  final String category;
  final LatLng center;

  const SearchPlacesEvent(this.category, this.center);

  @override
  List<Object> get props => [category, center];
}
