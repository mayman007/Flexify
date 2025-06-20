import 'package:flexify/src/views/favorites_view.dart';
import 'package:flexify/src/views/depthWall_view.dart';
import 'package:flexify/src/views/wallpapers_view.dart';
import 'package:flexify/src/views/widgets_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/settings_view.dart';
import 'package:easy_localization/easy_localization.dart';

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
          pageBuilder: (_, __, ___) => const DepthWallView(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WidgetsView(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const FavoritesView(),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      );
    } else if (index == 4) {
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
          label: context.tr('navigation.wallpapers'),
        ),
        NavigationDestination(
          icon: Icon(selectedIndex == 1
              ? Icons.photo_library_rounded
              : Icons.photo_library_outlined),
          label: context.tr('navigation.depthWalls'),
        ),
        NavigationDestination(
          icon: Icon(selectedIndex == 2
              ? Icons.widgets_rounded
              : Icons.widgets_outlined),
          label: context.tr('navigation.widgets'),
        ),
        NavigationDestination(
          icon: Icon(selectedIndex == 3
              ? Icons.favorite_rounded
              : Icons.favorite_outline_outlined),
          label: context.tr('navigation.favorites'),
        ),
        NavigationDestination(
          icon: Icon(selectedIndex == 4
              ? Icons.settings_rounded
              : Icons.settings_outlined),
          label: context.tr('navigation.settings'),
        ),
      ],
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: onNavTap,
    );
  }
}
