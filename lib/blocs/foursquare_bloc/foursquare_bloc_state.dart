import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class FoursquareBlocState extends Equatable {
  const FoursquareBlocState();

  @override
  List<Object?> get props => [];
}

class FoursquareBlocInitialState extends FoursquareBlocState {}

class FoursquareBlocLoadingState extends FoursquareBlocState {}

class FoursquareBlocLoadedState extends FoursquareBlocState {
  final Set<Marker> markers;

  const FoursquareBlocLoadedState(this.markers);

  @override
  List<Object?> get props => [markers];
}

class FoursquareBlocErrorState extends FoursquareBlocState {
  final String error;

  const FoursquareBlocErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
