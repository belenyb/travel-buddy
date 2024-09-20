import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../getX/place_detail_controller.dart';
import '../models/favorite_spot_model.dart';
import 'place_details_sheet_content.dart';

class PlaceDetailsSheet extends StatelessWidget {
  final String foursquareId;

  const PlaceDetailsSheet({
    Key? key,
    required this.foursquareId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlaceController placeController = Get.put(PlaceController());
    placeController.fetchPlaceDetails(foursquareId);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Obx(
        () {
          final FavoriteSpot? place = placeController.placeData.value;
          return SheetContent(
            place: place,
          );
        },
      ),
    );
  }
}
