import 'package:flexify/src/settings/settings_controller.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../provider/wallpaper_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WallpapersView extends StatefulWidget {
  const WallpapersView({super.key, required this.settingsController});

  static const routeName = '/wallpapers';

  final SettingsController settingsController;

  @override
  State<WallpapersView> createState() => _WallpapersViewState();
}

class _WallpapersViewState extends State<WallpapersView> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

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
    return Scaffold(
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
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: provider.wallpaperNames.length,
                itemBuilder: (context, index) {
                  final wallpaperUrl =
                      '${provider.baseUrl}/${provider.wallpaperNames[index]}';
                  final wallpaperName =
                      provider.wallpaperNames[index].split(".")[0];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: wallpaperUrl,
                          placeholder: (context, url) => Center(
                            child: Shimmer.fromColors(
                              baseColor: Theme.of(context).colorScheme.surface,
                              highlightColor: Colors.grey,
                              child: Container(
                                color: Colors.red,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              wallpaperName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      bottomNavigationBar: MaterialNavBar(
        selectedIndex: 0,
        settingsController: widget.settingsController,
      ),
    );
  }
}
