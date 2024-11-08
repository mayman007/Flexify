import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  static const routeName = '/favourites';

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favourites",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Center(child: Text("Coming soon...")),
          ],
        ),
      ),
      bottomNavigationBar: const MaterialNavBar(
        selectedIndex: 2,
      ),
    );
  }
}
