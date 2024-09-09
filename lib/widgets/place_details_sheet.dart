import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:travel_buddy/models/place_spot_model.dart';
import '../app_state.dart';
import '../getX/place_detail_controller.dart';

class SheetContent extends StatelessWidget {
  final bool isLoading;
  final PlaceSpot? place;
  final String? errorMessage;

  const SheetContent({
    Key? key,
    required this.isLoading,
    this.place,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                                  place?.name ?? "No name",
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
                                      place?.address ?? "No address",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                        "${place?.locality ?? 'No locality'}, ${place?.country ?? 'No country'}.")
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
                                  "${place?.categoryIconPrefix ?? ''}32${place?.categoryIconSuffix ?? ''}",
                                  color: Theme.of(context).primaryColor,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text("😢");
                                  },
                                ),
                                Text(
                                  place?.category ?? "No category",
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
                            label: const Text("Add to favorites"),
                            icon: const FaIcon(
                              FontAwesomeIcons.star,
                              size: 18,
                            ),
                            onPressed: () async {
                              final PlaceSpot favoriteSpot = PlaceSpot(
                                name: place?.name ?? "",
                                addedAt: DateTime.now(),
                                latitude: place?.latitude ?? 0.0,
                                longitude: place?.longitude ?? 0.0,
                                address: place?.address ?? "",
                                locality: place?.locality,
                                region: place?.region ?? "",
                                postcode: place?.postcode,
                                category: place?.category ?? "",
                                categoryIconPrefix:
                                    place?.categoryIconPrefix ?? "",
                                categoryIconSuffix:
                                    place?.categoryIconSuffix ?? "",
                                country: place?.country ?? "",
                              );

                              try {
                                User? user = AppState.currentUser;
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

                                  debugPrint(
                                      'Favorite spot added successfully!');
                                } else {
                                  debugPrint('User not logged in');
                                }
                              } catch (error) {
                                debugPrint('Error adding favorite: $error');
                              }
                            },
                          ),
                    if (isLoading) const SizedBox(height: 16),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorMessage!,
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

//
class PlaceDetailsSheet extends StatelessWidget {
  final String markerId;

  const PlaceDetailsSheet({
    Key? key,
    required this.markerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlaceController placeController = Get.put(PlaceController());
    placeController.fetchPlaceDetails(markerId);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Obx(() {
        if (placeController.isLoading.value) {
          return const SheetContent(isLoading: true);
        }

        if (placeController.errorMessage.value.isNotEmpty) {
          return SheetContent(
            isLoading: false,
            errorMessage: placeController.errorMessage.value,
          );
        }

        final place = placeController.placeData.value;

        return SheetContent(
          isLoading: false,
          place: place!,
        );
      }),
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
