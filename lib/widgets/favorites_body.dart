import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/foursquare_bloc/foursquare_bloc.dart';
import '../blocs/foursquare_bloc/foursquare_bloc_event.dart';
import '../models/favorite_spot_model.dart';
import '../singleton/favorites_service.dart';

class FavoritesBody extends StatefulWidget {
  const FavoritesBody({super.key});

  @override
  State<FavoritesBody> createState() => _FavoritesBodyState();
}

class _FavoritesBodyState extends State<FavoritesBody> {
  @override
  void initState() {
    super.initState();
    favoritesService.fetchFavoritesStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, List<FavoriteSpot>>>(
      stream: favoritesService.favoritesStream,
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, List<FavoriteSpot>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No favorites found'));
        }

        Map<String, List<FavoriteSpot>> groupedFavorites = snapshot.data!;
        List<String> categories = groupedFavorites.keys.toList();

        return ListView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, categoryIndex) {
            String category = categories[categoryIndex];
            List<FavoriteSpot> spots = groupedFavorites[category]!;

            List<Widget> categoryWidgets = [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      category,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Divider(color: Theme.of(context).primaryColor)
                ],
              ),
            ];

            for (var spot in spots) {
              categoryWidgets.add(
                ListTile(
                  leading: const Icon(Icons.location_pin,
                      size: 20, color: Colors.black38),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  title: Text(spot.name,
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(spot.address),
                  onTap: () {
                    Navigator.pop(context);
                    BlocProvider.of<FoursquareBloc>(context).add(
                      AddFavoriteMarkerEvent(
                        spot.foursquareId,
                        LatLng(spot.latitude, spot.longitude),
                        spot.name,
                      ),
                    );
                  },
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categoryWidgets,
            );
          },
        );
      },
    );
  }
}
