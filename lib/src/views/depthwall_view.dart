import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/provider/depthwall_provider.dart';
import 'package:flexify/src/views/depthwall_details_view.dart';
import 'package:flexify/src/utils/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

/// A view that displays a grid of depth-effect wallpapers.
class DepthWallView extends StatefulWidget {
  const DepthWallView({super.key});

  static const routeName = '/depthWall';

  @override
  State<DepthWallView> createState() => _DepthWallViewState();
}

/// State for [DepthWallView].
class _DepthWallViewState extends State<DepthWallView> {
  /// Set to track which images have been preloaded
  final Set<String> _preloadedImages = {};

  /// Number of images to preload ahead of viewport
  static const int _preloadBuffer = 15;

  /// Fetches depth wallpaper data from the [DepthWallProvider].
  Future fetchDepthWalls() async {
    final depthWallProvider =
        Provider.of<DepthWallProvider>(context, listen: false);
    depthWallProvider.fetchDepthWallData();
  }

  /// Preloads depth wallpaper thumbnail images for better user experience
  void _preloadImages(DepthWallProvider provider, int currentIndex) async {
    final startIndex = currentIndex;
    final endIndex = (currentIndex + _preloadBuffer)
        .clamp(0, provider.depthWallNames.length - 1);

    for (int i = startIndex; i <= endIndex; i++) {
      if (i >= provider.depthWallNames.length) break;

      final String depthWallName = provider.depthWallNames[i].split(".")[0];
      final String depthWallThumbnailUrl =
          '${provider.baseUrl}/$depthWallName.png';

      if (!_preloadedImages.contains(depthWallThumbnailUrl)) {
        _preloadedImages.add(depthWallThumbnailUrl);
        try {
          await precacheImage(NetworkImage(depthWallThumbnailUrl), context);
        } catch (e) {
          // Silently handle preload errors
          debugPrint(
              'Failed to preload depth wallpaper image: $depthWallThumbnailUrl');
        }
      }
    }
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Depth Wall View");
    final depthWallProvider =
        Provider.of<DepthWallProvider>(context, listen: false);

    if (depthWallProvider.depthWallNames.isEmpty) {
      // Fetch widget names on screen load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchDepthWalls();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
          tag: 'app-bar',
          child: AppBar(
            title: Text(
              context.tr('depthWalls.title'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchDepthWalls,
        child: Consumer<DepthWallProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '( ︶︹︶ )',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Connection Error',
                          style: TextStyle(fontSize: 25),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 34,
                        ),
                      ],
                    ),
                    TextButton(
                        onPressed: fetchDepthWalls,
                        child: Text(context.tr('common.tryAgain')))
                  ],
                ),
              );
            } else if (provider.depthWallNames.isEmpty) {
              return Center(child: Text(context.tr('depthWalls.fetching')));
            } else {
              // Start preloading images
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _preloadImages(provider, 0);
              });

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo is ScrollUpdateNotification) {
                    // Calculate current visible item index and preload ahead
                    final currentIndex =
                        (scrollInfo.metrics.pixels / 240).floor();
                    _preloadImages(provider, currentIndex);
                  }
                  return false;
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 2 / 4,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.depthWallNames.length,
                  itemBuilder: (context, index) {
                    final String depthWallName =
                        provider.depthWallNames[index].split(".")[0];
                    final String depthWallExtension =
                        provider.depthWallNames[index].split(".")[1];
                    final String depthWallUrl =
                        '${provider.baseUrl}/$depthWallName.$depthWallExtension';
                    final String depthWallThumbnailUrl =
                        '${provider.baseUrl}/$depthWallName.png';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            builder: (context) => DepthWallDetailsView(
                              depthWallUrl: depthWallUrl,
                              depthWallThumbnailUrl: depthWallThumbnailUrl,
                              depthWallName: depthWallName,
                            ),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );
                      },
                      child: WallpaperCard(
                        wallpaperUrlHq: depthWallThumbnailUrl,
                        wallpaperUrlMid: depthWallThumbnailUrl,
                        wallpaperUrlLow: depthWallThumbnailUrl,
                        isWallpaper: true,
                        lowQuality: true,
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
