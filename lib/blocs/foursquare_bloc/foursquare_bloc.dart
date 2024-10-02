import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_buddy/blocs/foursquare_bloc/foursquare_bloc_event.dart';
import '../../theme/create_custom_marker.dart';
import 'foursquare_bloc_state.dart';

class FoursquareBloc extends Bloc<FoursquareBlocEvent, FoursquareBlocState> {
  FoursquareBloc() : super(FoursquareBlocInitialState()) {
    on<SearchPlacesEvent>(_onSearchPlacesEvent);
    on<AddFavoriteMarkerEvent>(_onAddFavoriteMarkerEvent);
  }

  Future<void> _onSearchPlacesEvent(
      SearchPlacesEvent event, Emitter<FoursquareBlocState> emit) async {
    emit(FoursquareBlocLoadingState());
    final BitmapDescriptor markerPin = await createCustomMarker("red");

    try {
      final String? apiKey = dotenv.env['FOURSQUARE_API_KEY'];
      final response = await http.get(
        Uri.parse(
          'https://api.foursquare.com/v3/places/search?ll=${event.center.latitude},${event.center.longitude}&categories=${event.category}&radius=6000',
        ),
        headers: {
          'Authorization': apiKey!,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Set<Marker> markers = {};
        for (var item in data['results']) {
          final Marker marker = Marker(
            markerId: MarkerId(item['fsq_id']),
            position: LatLng(
              item['geocodes']['main']['latitude'],
              item['geocodes']['main']['longitude'],
            ),
            infoWindow: InfoWindow(
              title: item['name'],
              snippet: item['location']['address'],
            ),
            icon: markerPin,
          );
          markers.add(marker);
        }
        emit(FoursquareBlocLoadedState(markers));
      } else {
        emit(const FoursquareBlocErrorState('Failed to load places'));
      }
    } catch (e) {
      emit(FoursquareBlocErrorState(e.toString()));
    }
  }

  Future<void> _onAddFavoriteMarkerEvent(
      AddFavoriteMarkerEvent event, Emitter<FoursquareBlocState> emit) async {
    emit(FoursquareBlocLoadingState());

    final BitmapDescriptor customMarker = await createCustomMarker("favorite");

    try {
      // Create the new marker
      final Marker newMarker = Marker(
        markerId: MarkerId(event.markerId),
        position: event.position,
        infoWindow: InfoWindow(title: event.title),
        icon: customMarker,
      );

      // Emit the updated state with the new marker
      emit(FoursquareBlocFavoriteMarkedState(newMarker));
    } catch (e) {
      emit(FoursquareBlocErrorState(e.toString()));
    }
  }
}
