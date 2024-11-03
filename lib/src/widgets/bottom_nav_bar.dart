import 'package:flexify/src/views/wallpapers_view.dart';
import 'package:flexify/src/views/widgets_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings/settings_controller.dart';
import '../views/settings_view.dart';

class MaterialNavBar extends StatefulWidget {
  final int selectedIndex;
  final SettingsController settingsController;

  const MaterialNavBar({
    super.key,
    required this.selectedIndex,
    required this.settingsController,
  });

  @override
  State<MaterialNavBar> createState() => _MaterialNavBarState();
}

class _MaterialNavBarState extends State<MaterialNavBar> {
  int selectedIndex = 0;
  onNavTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              WallpapersView(settingsController: widget.settingsController),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              WidgetsView(settingsController: widget.settingsController),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              SettingsView(controller: widget.settingsController),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  String darkThemeValue = 'Dim';
  String materialYou = 'Dim';

  getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? darkTheme = prefs.getString('darkTheme');
    bool? materialYou = prefs.getBool('materialYou');
    setState(() {
      if (darkTheme == null || darkTheme == 'Dim') {
        darkThemeValue = 'Dim';
      } else if (darkTheme == 'Lights out') {
        darkThemeValue = 'Lights out';
      }
      if (materialYou != null) {
        materialYou = materialYou;
      }
    });
  }

  @override
  void initState() {
    getPrefs();
    setState(() {
      selectedIndex = widget.selectedIndex;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      animationDuration: const Duration(seconds: 1),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? darkThemeValue == 'Lights out ' || materialYou == false
              ? Colors.black
              : Theme.of(context).scaffoldBackgroundColor
          : Theme.of(context).scaffoldBackgroundColor,
      destinations: [
        NavigationDestination(
          icon: Icon(selectedIndex == 0
              ? Icons.wallpaper_rounded
              : Icons.wallpaper_outlined),
          label: 'Wallpapers',
        ),
        NavigationDestination(
          icon: Icon(selectedIndex == 1
              ? Icons.widgets_rounded
              : Icons.widgets_outlined),
          label: 'Widgets',
        ),
        NavigationDestination(
          icon: Icon(selectedIndex == 2
              ? Icons.settings_rounded
              : Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: onNavTap,
    );
  }
}
