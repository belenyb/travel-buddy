import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:travel_buddy/models/place_spot_model.dart';
import '../app_state.dart';
import '../getX/place_detail_controller.dart';

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
          place: place,
        );
      }),
    );
  }
}

class SheetContent extends StatelessWidget {
  final bool isLoading;
  final Map? place;
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
                                  place!["name"],
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
                                      place!["address"],
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    Text(
                                        "${place!["locality"]}, ${place!["country"]}.")
                                  ],
                                ),
                        ],
                      ),
                    ),
                    isLoading
                        ? const Skeleton(width: 150, height: 55)
                        : Chip(
                            // backgroundColor: Theme.of(context).primaryColor,
                            label: Row(
                              children: [
                                Image.network(
                                  "${place?["categoryIcon"]["prefix"]}32${place?["categoryIcon"]["suffix"]}",
                                  color: Colors.black87,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text("😢");
                                  },
                                ),
                                Text(
                                  place!["category"],
                                  style: Theme.of(context)
                                      .chipTheme
                                      .secondaryLabelStyle,
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
                                  name: place?["name"] ?? "No name",
                                  addedAt: DateTime.now(),
                                  latitude: place?["latitude"] ?? 0,
                                  longitude: place?["longitude"] ?? 0,
                                  address: place?["address"] ?? "No address",
                                  locality: place?["locality"] ?? "No locality",
                                  region: place?["region"] ?? "No region",
                                  postcode: place?["postcode"] ?? "No postcode",
                                  category: place?["category"] ?? "No category",
                                  categoryIcon: place?["categoryIcon"]
                                                  ["prefix"] !=
                                              "" &&
                                          place?["categoryIcon"]["suffix"] != ""
                                      ? {
                                          "prefix": place?["categoryIcon"]
                                                  ["prefix"] ??
                                              "",
                                          "suffix": place?["categoryIcon"]
                                                  ["suffix"] ??
                                              "",
                                        }
                                      : {});

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
                                  await favoritesCollection.add(favoriteSpot);

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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         isLoading
                    //             ? const Skeleton(width: 130, height: 25)
                    //             : Row(
                    //                 children: [
                    //                   const FaIcon(FontAwesomeIcons.clock,
                    //                       size: 16),
                    //                   const SizedBox(width: 6),
                    //                   // Text(place!.hours.display,
                    //                   Text("place!.hours.display",
                    //                       style: Theme.of(context)
                    //                           .textTheme
                    //                           .bodyLarge),
                    //                 ],
                    //               ),
                    //         if (isLoading) const SizedBox(height: 4),
                    // if (place!.hours.openNow != null)
                    // isLoading
                    // ? const Skeleton(width: 100, height: 17)
                    // : Text(
                    // "place!.hours.display",
                    // place!.hours.openNow == true
                    //     ? "Now open!"
                    //     : "Closed",
                    // style: Theme.of(context)
                    // .textTheme
                    // .bodyLarge!
                    // .copyWith(
                    // color:
                    // place!.hours.openNow == true
                    // ?
                    // Colors.green[600]
                    // : Colors.red[600],
                    // ),
                    // ),
                    //     ],
                    //   ),
                    //   isLoading
                    //       ? const Skeleton(width: 200, height: 30)
                    //       : Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             TextButton(
                    //               onPressed: () {},
                    //               style: TextButton.styleFrom(
                    //                   padding: EdgeInsets.zero,
                    //                   tapTargetSize:
                    //                       MaterialTapTargetSize.shrinkWrap),
                    //               child: const FaIcon(FontAwesomeIcons.facebookF,
                    //                   size: 16),
                    //             ),
                    //             TextButton(
                    //               onPressed: () {},
                    //               child: const FaIcon(FontAwesomeIcons.instagram,
                    //                   size: 16),
                    //             ),
                    //             TextButton(
                    //               onPressed: () {},
                    //               child: const FaIcon(FontAwesomeIcons.xTwitter,
                    //                   size: 16),
                    //             ),
                    //           ],
                    //         ),
                    // ],
                    // ),
                    // const SizedBox(height: 12),
                    // if (place!.photos.isNotEmpty)
                    // isLoading
                    // ? const Skeleton(width: 200, height: 200)
                    // : Image.network(place!.photos.first.tip.url),
                    // const SizedBox(height: 12),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //       child: isLoading
                    //           ? const Skeleton(width: 200, height: 50)
                    //           : Text(
                    //               place!.description,
                    //               style: Theme.of(context).textTheme.titleMedium,
                    //             ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     isLoading
                    //         ? const Skeleton(width: 40, height: 30)
                    //         : Text(place!.rating.toString(),
                    //             style: Theme.of(context).textTheme.titleMedium),
                    //   ],
                    // ),
                    // const SizedBox(height: 12),
                    // isLoading
                    //     ? const Skeleton(width: 240, height: 30)
                    //     : Row(
                    //         children: [
                    //           TextButton(
                    //             onPressed: () {},
                    //             child: Row(
                    //               children: [
                    //                 const FaIcon(FontAwesomeIcons.phone, size: 16),
                    //                 const SizedBox(width: 6),
                    //                 Text(place!.tel),
                    //               ],
                    //             ),
                    //           ),
                    //           TextButton(
                    //             onPressed: () {},
                    //             child: Row(
                    //               children: [
                    //                 const FaIcon(FontAwesomeIcons.globe),
                    //                 const SizedBox(width: 6),
                    //                 Text(place!.website),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
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

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class PlaceDetailsSheet extends StatelessWidget {
//   final String markerId;
//   const PlaceDetailsSheet({
//     super.key,
//     required this.markerId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24.0),
//           topRight: Radius.circular(24.0),
//         ),
//       ),
//       child: FutureBuilder(
//         future: Future.delayed(const Duration(seconds: 4)),
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return SheetContent(isLoading: true);
//           } else {
//             return SheetContent(isLoading: false);
//           }
//         },
//       ),
//     );
//   }
// }

// class SheetContent extends StatelessWidget {
//   final bool isLoading;
//   const SheetContent({
//     super.key,
//     required this.isLoading,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Wrap(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 30,
//                 margin: const EdgeInsets.only(top: 8, bottom: 10),
//                 child: const Divider(
//                   thickness: 3.5,
//                   height: 10,
//                   color: Colors.black54,
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         isLoading
//                             ? const Skeleton(width: 150, height: 25)
//                             : Text(
//                                 'Nombre del lugar',
//                                 style: Theme.of(context).textTheme.titleLarge,
//                               ),
//                         if (isLoading) const SizedBox(height: 8),
//                         isLoading
//                             ? const Skeleton(width: 200, height: 17)
//                             : const Text("Av. Siempre Viva 1234, Buenos Aires"),
//                       ],
//                     ),
//                     isLoading
//                         ? const Skeleton(width: 100, height: 42)
//                         : Chip(
//                             label: Text(
//                               "Category",
//                               style: Theme.of(context)
//                                   .chipTheme
//                                   .secondaryLabelStyle,
//                             ),
//                           )
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         isLoading
//                             ? const Skeleton(width: 130, height: 25)
//                             : Row(
//                                 children: [
//                                   const FaIcon(
//                                     FontAwesomeIcons.clock,
//                                     size: 16,
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text("18hs - 21hs",
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyLarge),
//                                 ],
//                               ),
//                         if (isLoading) const SizedBox(height: 4),
//                         isLoading
//                             ? const Skeleton(width: 100, height: 17)
//                             : Text(
//                                 "Now open!",
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyLarge!
//                                     .copyWith(color: Colors.green[600]),
//                               )
//                       ],
//                     ),
//                     isLoading
//                         ? const Skeleton(width: 200, height: 30)
//                         : Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               TextButton(
//                                   onPressed: () {},
//                                   style: TextButton.styleFrom(
//                                       padding: EdgeInsets.zero,
//                                       tapTargetSize:
//                                           MaterialTapTargetSize.shrinkWrap),
//                                   child: const FaIcon(
//                                       FontAwesomeIcons.facebookF,
//                                       size: 16)),
//                               TextButton(
//                                   onPressed: () {},
//                                   child: const FaIcon(
//                                       FontAwesomeIcons.instagram,
//                                       size: 16)),
//                               TextButton(
//                                   onPressed: () {},
//                                   child: const FaIcon(FontAwesomeIcons.xTwitter,
//                                       size: 16)),
//                             ],
//                           ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 isLoading
//                     ? const Skeleton(width: 200, height: 200)
//                     : Image.network("https://picsum.photos/200"),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: isLoading
//                           ? const Skeleton(width: 200, height: 50)
//                           : Text(
//                               "Description of the place maybe a bit longer we will add it later",
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                     ),
//                     const SizedBox(width: 12),
//                     isLoading
//                         ? const Skeleton(width: 40, height: 30)
//                         : Text("4.5",
//                             style: Theme.of(context).textTheme.titleMedium),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 isLoading
//                     ? const Skeleton(width: 240, height: 30)
//                     : Row(
//                         children: [
//                           TextButton(
//                             onPressed: () {},
//                             child: const Row(
//                               children: [
//                                 FaIcon(
//                                   FontAwesomeIcons.phone,
//                                   size: 16,
//                                 ),
//                                 SizedBox(width: 6),
//                                 Text("011 1121 2121"),
//                               ],
//                             ),
//                           ),
//                           TextButton(
//                               onPressed: () {},
//                               child: const Row(children: [
//                                 FaIcon(FontAwesomeIcons.globe),
//                                 SizedBox(
//                                   width: 6,
//                                 ),
//                                 Text("website")
//                               ])),
//                         ],
//                       ),
//                 if (isLoading) const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
