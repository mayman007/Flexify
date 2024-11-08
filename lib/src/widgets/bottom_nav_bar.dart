import 'package:flexify/src/views/favourites_view.dart';
import 'package:flexify/src/views/wallpapers_view.dart';
import 'package:flexify/src/views/widgets_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/settings_view.dart';

class MaterialNavBar extends StatefulWidget {
  final int selectedIndex;

  const MaterialNavBar({
    super.key,
    required this.selectedIndex,
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
          pageBuilder: (_, __, ___) => const WallpapersView(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WidgetsView(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const FavouritesView(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SettingsView(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    }
  }

  bool isPureBlackEnabledValue = true;
  bool materialYouValue = false;

  getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isPureBlackEnabledPref = prefs.getBool('isPureBlackEnabled');
    bool? materialYouPref = prefs.getBool('materialYou');
    setState(() {
      if (isPureBlackEnabledPref == null || isPureBlackEnabledPref == false) {
        isPureBlackEnabledValue = false;
      } else if (isPureBlackEnabledPref == true) {
        isPureBlackEnabledValue = true;
      }
      if (materialYouPref != null) {
        materialYouValue = materialYouPref;
      }
    });
  }

  @override
  void initState() {
    setState(() {
      selectedIndex = widget.selectedIndex;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getPrefs();
    return NavigationBar(
      animationDuration: const Duration(seconds: 1),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? isPureBlackEnabledValue
              ? Colors.black
              : null
          : null,
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
              ? Icons.favorite_rounded
              : Icons.favorite_outline_outlined),
          label: 'Favourites',
        ),
        NavigationDestination(
          icon: Icon(selectedIndex == 3
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
