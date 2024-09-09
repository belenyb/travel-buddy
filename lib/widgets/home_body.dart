import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/foursquare_bloc/foursquare_bloc.dart';
import 'google_map_widget.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => FoursquareBloc(), child: const GoogleMapWidget());
  }
}
