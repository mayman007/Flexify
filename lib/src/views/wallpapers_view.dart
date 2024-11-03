import 'package:flexify/src/settings/settings_controller.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class WallpapersView extends StatefulWidget {
  const WallpapersView({super.key, required this.settingsController});

  static const routeName = '/wallpapers';

  final SettingsController settingsController;

  @override
  State<WallpapersView> createState() => _WallpapersViewState();
}

class _WallpapersViewState extends State<WallpapersView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Wallpapers",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("This is the wallpapers view"),
          ],
        ),
      ),
      bottomNavigationBar: MaterialNavBar(
        selectedIndex: 0,
        settingsController: widget.settingsController,
      ),
    );
  }
}
