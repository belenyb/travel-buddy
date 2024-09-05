import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_buddy/blocs/foursquare_bloc/foursquare_bloc_event.dart';

import 'foursquare_bloc_state.dart';

class FoursquareBloc extends Bloc<FoursquareBlocEvent, FoursquareBlocState> {
  FoursquareBloc() : super(FoursquareBlocInitialState()) {
    on<SearchPlacesEvent>(_onSearchPlacesEvent);
  }
}

Future<void> _onSearchPlacesEvent(
    SearchPlacesEvent event, Emitter<FoursquareBlocState> emit) async {
  emit(FoursquareBlocLoadingState());

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
              title: item['name'], snippet: item['location']['address']),
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