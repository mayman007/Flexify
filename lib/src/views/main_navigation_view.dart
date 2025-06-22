import 'package:flexify/src/views/favorites_view.dart';
import 'package:flexify/src/views/depthWall_view.dart';
import 'package:flexify/src/views/wallpapers_view.dart';
import 'package:flexify/src/views/widgets_view.dart';
import 'package:flexify/src/views/settings_view.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flexify/src/widgets/keep_alive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainNavigationView extends StatefulWidget {
  final int initialIndex;

  const MainNavigationView({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    KeepAlivePage(child: WallpapersView()),
    KeepAlivePage(child: DepthWallView()),
    KeepAlivePage(child: WidgetsView()),
    KeepAlivePage(child: FavoritesView()),
    KeepAlivePage(child: SettingsView()),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(() {
      final pageIndex = _pageController.page?.round() ?? 0;
      if (pageIndex != _currentIndex) {
        setState(() {
          _currentIndex = pageIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarDividerColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            Stack(
              children: List.generate(
                _pages.length,
                (index) => AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _currentIndex == index ? 1.0 : 0.0,
                  child: HeroMode(
                    enabled: _currentIndex == index,
                    child: IgnorePointer(
                      ignoring: _currentIndex != index,
                      child: _pages[index],
                    ),
                  ),
                ),
              ),
            ),
            Offstage(
              offstage: true,
              child: PageView(
                controller: _pageController,
                children: List.generate(5, (_) => const SizedBox.shrink()),
              ),
            )
          ],
        ),
        bottomNavigationBar: Hero(
          tag: 'bottom-nav-bar',
          child: MaterialNavBar(
            selectedIndex: _currentIndex,
            pageController: _pageController,
          ),
        ),
      ),
    );
  }
}
