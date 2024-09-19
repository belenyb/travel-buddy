import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travel_buddy/widgets/favorites_body.dart';
import '../app_state.dart';
import '../auth/firebase_user_repository.dart';
import '../widgets/home_body.dart';

class LayoutScreen extends StatefulWidget {
  static const String routeName = "/main";
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  static const List<Widget> widgetOptions = <Widget>[
    HomeBody(),
    FavoritesBody()
  ];

  void onItemTapped(int index) {
    if (index == 1) {
      // Open the drawer using the GlobalKey
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseUserRepository userRepository = FirebaseUserRepository();
    final User? currentUser = AppState.currentUser;

    return Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Favorites",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Expanded(child: FavoritesBody()),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          leading: Icon(
            Icons.travel_explore,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(currentUser!.email!),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () async {
                await userRepository.signOut();
                Navigator.pushReplacementNamed(context, "/auth");
              },
            ),
          ],
        ),
        body: Builder(
          builder: (BuildContext innerContext) {
            return Center(
              child: widgetOptions.elementAt(selectedIndex),
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: selectedIndex,
          onItemTapped: onItemTapped,
        ));
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int)? onItemTapped;
  const CustomBottomNavigationBar(
      {super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.house),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.star),
          label: 'Favorites',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
