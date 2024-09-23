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
    return StreamBuilder<List<FavoriteSpot>>(
      stream: favoritesService.favoritesStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<FavoriteSpot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No favorites found'));
        }

        List<FavoriteSpot> favorites = snapshot.data!;

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            return ListTile(
              title: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  BlocProvider.of<FoursquareBloc>(context).add(
                    AddFavoriteMarkerEvent(
                      favorite.foursquareId,
                      LatLng(favorite.latitude, favorite.longitude),
                      favorite.name,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(favorite.name),
                    Text(favorite.address),
                  ],
                ),
              ),
              subtitle: Text(favorite.category),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  await favoritesService.deleteFavorite(favorite.id!);
                },
              ),
            );
          },
        );
      },
    );
  }
}
