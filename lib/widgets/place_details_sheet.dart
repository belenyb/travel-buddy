import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlaceDetailsSheet extends StatelessWidget {
  final String markerId;
  const PlaceDetailsSheet({
    super.key,
    required this.markerId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 4)),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SheetContent(isLoading: true);
          } else {
            return SheetContent(isLoading: false);
          }
        },
      ),
    );
  }
}

class SheetContent extends StatelessWidget {
  final bool isLoading;
  const SheetContent({
    super.key,
    required this.isLoading,
  });

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading
                            ? const Skeleton(width: 150, height: 25)
                            : Text(
                                'Nombre del lugar',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                        if (isLoading) const SizedBox(height: 8),
                        isLoading
                            ? const Skeleton(width: 200, height: 17)
                            : const Text("Av. Siempre Viva 1234, Buenos Aires"),
                      ],
                    ),
                    isLoading
                        ? const Skeleton(width: 100, height: 42)
                        : Chip(
                            label: Text(
                              "Category",
                              style: Theme.of(context)
                                  .chipTheme
                                  .secondaryLabelStyle,
                            ),
                          )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading
                            ? const Skeleton(width: 130, height: 25)
                            : Row(
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.clock,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text("18hs - 21hs",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge),
                                ],
                              ),
                        if (isLoading) const SizedBox(height: 4),
                        isLoading
                            ? const Skeleton(width: 100, height: 17)
                            : Text(
                                "Now open!",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.green[600]),
                              )
                      ],
                    ),
                    isLoading
                        ? const Skeleton(width: 200, height: 30)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap),
                                  child: const FaIcon(
                                      FontAwesomeIcons.facebookF,
                                      size: 16)),
                              TextButton(
                                  onPressed: () {},
                                  child: const FaIcon(
                                      FontAwesomeIcons.instagram,
                                      size: 16)),
                              TextButton(
                                  onPressed: () {},
                                  child: const FaIcon(FontAwesomeIcons.xTwitter,
                                      size: 16)),
                            ],
                          ),
                  ],
                ),
                const SizedBox(height: 12),
                isLoading
                    ? const Skeleton(width: 200, height: 200)
                    : Image.network("https://picsum.photos/200"),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: isLoading
                          ? const Skeleton(width: 200, height: 50)
                          : Text(
                              "Description of the place maybe a bit longer we will add it later",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                    ),
                    const SizedBox(width: 12),
                    isLoading
                        ? const Skeleton(width: 40, height: 30)
                        : Text("4.5",
                            style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                isLoading
                    ? const Skeleton(width: 240, height: 30)
                    : Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.phone,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text("011 1121 2121"),
                              ],
                            ),
                          ),
                          TextButton(
                              onPressed: () {},
                              child: const Row(children: [
                                FaIcon(FontAwesomeIcons.globe),
                                SizedBox(
                                  width: 6,
                                ),
                                Text("website")
                              ])),
                        ],
                      ),
                if (isLoading) const SizedBox(height: 16),
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
