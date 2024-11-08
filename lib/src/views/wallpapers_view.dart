import 'package:flexify/src/views/wallpaper_details_view.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../provider/wallpaper_provider.dart';

class WallpapersView extends StatefulWidget {
  const WallpapersView({super.key});

  static const routeName = '/wallpapers';

  @override
  State<WallpapersView> createState() => _WallpapersViewState();
}

class _WallpapersViewState extends State<WallpapersView> {
  @override
  void initState() {
    final wallpaperProvider =
        Provider.of<WallpaperProvider>(context, listen: false);

    if (wallpaperProvider.wallpaperNames.isEmpty) {
      // Fetch wallpaper names on screen load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wallpaperProvider.fetchWallpaperNames();
      });
    }

    super.initState();
  }

  Future fetchWallpapers() async {
    final wallpaperProvider =
        Provider.of<WallpaperProvider>(context, listen: false);
    wallpaperProvider.fetchWallpaperNames();
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
        appBar: AppBar(
          title: const Text(
            "Wallpapers",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Consumer<WallpaperProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.wallpaperNames.isEmpty) {
              return const Center(child: Text('Fetching Wallpapers...'));
            } else {
              return LiquidPullToRefresh(
                onRefresh: fetchWallpapers,
                showChildOpacityTransition: false,
                color: Theme.of(context).colorScheme.inversePrimary,
                child: GridView.builder(
                  key: const PageStorageKey(
                      'wallpapersGrid'), // Add PageStorageKey
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 3 / 4,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.wallpaperNames.length,
                  itemBuilder: (context, index) {
                    final wallpaperUrl =
                        '${provider.baseUrl}/${provider.wallpaperNames[index]}';
                    final wallpaperName =
                        provider.wallpaperNames[index].split("@")[0];
                    final wallpaperAuthor = provider.wallpaperNames[index]
                        .split("@")[1]
                        .split(".")[0];
                    final uniqueKey = UniqueKey();

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            builder: (context) => WallpaperDetailsView(
                              wallpaperUrl: wallpaperUrl,
                              wallpaperName: wallpaperName,
                              wallpaperAuthor: wallpaperAuthor,
                              uniqueKey: uniqueKey,
                            ),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );
                      },
                      child: WallpaperCard(
                        wallpaperUrl: wallpaperUrl,
                        uniqueKey: uniqueKey,
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
        bottomNavigationBar: const MaterialNavBar(
          selectedIndex: 0,
        ),
      ),
    );
  }
}
