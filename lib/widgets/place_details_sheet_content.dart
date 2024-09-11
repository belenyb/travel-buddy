import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material_icons;
import 'package:get/get.dart';
import '../app_state.dart';
import '../getX/place_detail_controller.dart';
import '../models/favorite_spot_model.dart';

class SheetContent extends StatefulWidget {
  final FavoriteSpot? place;
  final String? errorMessage;

  const SheetContent({
    Key? key,
    required this.place,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<SheetContent> {
  bool isFavorite = false;
  String? favoriteId;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final User? user = AppState.currentUser;

    if (user != null && widget.place != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference favoritesCollection =
          firestore.collection('users').doc(user.uid).collection('favorites');

      final querySnapshot = await favoritesCollection
          .where('name', isEqualTo: widget.place!.name)
          .where('latitude', isEqualTo: widget.place!.latitude)
          .where('longitude', isEqualTo: widget.place!.longitude)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        favoriteId = querySnapshot.docs[0].id;
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  Future<void> removeFromFavorites() async {
    final User? user = AppState.currentUser;

    if (user != null && favoriteId != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference favoritesCollection =
          firestore.collection('users').doc(user.uid).collection('favorites');

      try {
        await favoritesCollection.doc(favoriteId).delete();
        setState(() {
          isFavorite = false;
          favoriteId = null;
        });
        log("Favorite deleted successfully!");
      } catch (error) {
        debugPrint(error.toString());
      }
    } else {
      log("User not logged in or favorite ID unavailable.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlaceController placeController = Get.put(PlaceController());
    final bool isLoading = placeController.isLoading.value;

    return SafeArea(
      child: Wrap(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isLoading
                              ? const Skeleton(width: 150, height: 30)
                              : Text(
                                  widget.place?.name ?? "No name",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                          if (isLoading) const SizedBox(height: 8),
                          isLoading
                              ? const Skeleton(width: 200, height: 40)
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.place?.address ?? "No address",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                        "${widget.place?.locality ?? 'No locality'}, ${widget.place?.country ?? 'No country'}.")
                                  ],
                                ),
                        ],
                      ),
                    ),
                    isLoading
                        ? const Skeleton(width: 150, height: 55)
                        : Chip(
                            label: Row(
                              children: [
                                Image.network(
                                  "${widget.place?.categoryIconPrefix ?? ''}32${widget.place?.categoryIconSuffix ?? ''}",
                                  color: Theme.of(context).primaryColor,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text("😢");
                                  },
                                ),
                                Text(
                                  widget.place?.category ?? "No category",
                                  style: Theme.of(context)
                                      .chipTheme
                                      .secondaryLabelStyle
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? const Skeleton(width: 140, height: 25)
                        : TextButton.icon(
                            label: Text(isFavorite
                                ? "Remove from favorites"
                                : "Add to favorites"),
                            icon: material_icons.Icon(
                              isFavorite
                                  ? Icons.star
                                  : Icons.star_border_outlined,
                              size: 18,
                            ),
                            onPressed: () async {
                              User? user = AppState.currentUser;
                              _checkIfFavorite();
                              if (isFavorite) {
                                await removeFromFavorites();
                              } else {
                                final FavoriteSpot favoriteSpot = FavoriteSpot(
                                  name: widget.place?.name ?? "",
                                  addedAt: DateTime.now(),
                                  latitude: widget.place?.latitude ?? 0.0,
                                  longitude: widget.place?.longitude ?? 0.0,
                                  address: widget.place?.address ?? "",
                                  locality: widget.place?.locality,
                                  region: widget.place?.region ?? "",
                                  postcode: widget.place?.postcode,
                                  category: widget.place?.category ?? "",
                                  categoryIconPrefix:
                                      widget.place?.categoryIconPrefix ?? "",
                                  categoryIconSuffix:
                                      widget.place?.categoryIconSuffix ?? "",
                                  country: widget.place?.country ?? "",
                                );

                                try {
                                  if (user != null) {
                                    String userId = user.uid;
                                    CollectionReference favoritesCollection =
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .collection('favorites');

                                    // Add the favorite spot to the collection
                                    await favoritesCollection
                                        .add(favoriteSpot.toMap());

                                    setState(() {
                                      isFavorite = true;
                                    });

                                    log('Favorite spot added successfully!');
                                  } else {
                                    log('User not logged in');
                                  }
                                } catch (error) {
                                  log('Error adding favorite: $error');
                                }
                              }
                            },
                          ),
                    if (isLoading) const SizedBox(height: 16),
                    if (placeController.errorMessage.value != "")
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Skeleton extends StatefulWidget {
  const Skeleton({Key? key, this.height, this.width}) : super(key: key);

  final double? height, width;

  @override
  SkeletonState createState() => SkeletonState();
}

class SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          padding: const EdgeInsets.all(8 / 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2), // Base color
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(-_animation.value, 0),
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.2),
              ],
              stops: const [0.2, 0.25, 1],
            ),
          ),
        );
      },
    );
  }
}
