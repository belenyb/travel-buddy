import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late final PlaceController placeController;

  @override
  void initState() {
    placeController = Get.find<PlaceController>();
    super.initState();
  }

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
            child: Obx(
              () {
                final bool isLoading = placeController.isLoading.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading
                        ? const Skeleton(width: 150, height: 45)
                        : Chip(
                            padding: EdgeInsets.zero,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
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
                              if (widget.place!.address != "")
                                Text(
                                  widget.place!.address,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              Text(
                                  "${widget.place?.locality ?? 'No locality'}, ${widget.place?.country ?? 'No country'}.")
                            ],
                          ),
                    const SizedBox(height: 24),
                    isLoading
                        ? const Center(child: Skeleton(width: 140, height: 25))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StreamBuilder<bool>(
                                stream: placeController.isFavoriteStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Skeleton(
                                        width: 140, height: 25);
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data == true) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await placeController
                                            .removeFromFavorites();
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Color.fromARGB(
                                                255, 254, 230, 12),
                                            size: 28,
                                          ),
                                          SizedBox(width: 8),
                                          Text("Remove from favorites"),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return GestureDetector(
                                      onTap: () async {
                                        await placeController
                                            .addToFavorites(widget.place);
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.star_outline,
                                            size: 28,
                                          ),
                                          SizedBox(width: 8),
                                          Text("Add to favorites"),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                    if (isLoading) const SizedBox(height: 16),
                    if (placeController.errorMessage.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                );
              },
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
