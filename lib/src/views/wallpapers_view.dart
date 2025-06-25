import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/views/wallpaper_details_view.dart';
import 'package:flexify/src/views/wallpapers_category_view.dart';
import 'package:flexify/src/utils/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/wallpaper_provider.dart';

/// A view that displays a grid of wallpapers.
class WallpapersView extends StatefulWidget {
  const WallpapersView({super.key});

  static const routeName = '/wallpapers';

  @override
  State<WallpapersView> createState() => _WallpapersViewState();
}

/// State for [WallpapersView].
class _WallpapersViewState extends State<WallpapersView> {
  /// Caches preview image URLs for each category.
  final Map<String, String?> _categoryPreviewUrls = {};

  /// Set to track which images have been preloaded
  final Set<String> _preloadedImages = {};

  /// Set to track currently visible images
  final Set<String> _visibleImages = {};

  /// Number of images to preload ahead of viewport (reduced for memory optimization)
  static const int _preloadBuffer = 6;

  /// Maximum number of images to keep in cache
  static const int _maxCacheSize = 20;

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Wallpapers View");
    final wallpaperProvider =
        Provider.of<WallpaperProvider>(context, listen: false);

    if (wallpaperProvider.wallpaperNames.isEmpty) {
      // Fetch wallpaper names on screen load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchWallpapers();
      });
    }
    super.initState();
  }

  /// Fetches wallpaper data from the [WallpaperProvider].
  Future fetchWallpapers() async {
    final wallpaperProvider =
        Provider.of<WallpaperProvider>(context, listen: false);
    wallpaperProvider.fetchWallpaperData();
  }

  /// Displays a modal bottom sheet with a list of wallpaper categories.
  _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          final provider =
              Provider.of<WallpaperProvider>(context, listen: false);

          if (_categoryPreviewUrls.isEmpty &&
              provider.categoriesList.isNotEmpty) {
            for (final categoryName in provider.categoriesList) {
              _categoryPreviewUrls[categoryName] =
                  provider.getCategoryPreviewImage(categoryName);
            }
          }

          return Container(
            height: MediaQuery.sizeOf(context).height / 1.7,
            color: Colors.transparent,
            child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50))),
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 40),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 3 / 1,
                    crossAxisCount: 1,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: provider.categoriesList.length,
                  itemBuilder: (context, index) {
                    final String categoryName = provider.categoriesList[index];
                    final String categoryUrlHq =
                        "${provider.baseUrlHq}/$categoryName";
                    final String categoryUrlMid =
                        "${provider.baseUrlMid}/$categoryName";
                    final String categoryUrlLow =
                        "${provider.baseUrlLow}/$categoryName";
                    final String? previewImageUrl =
                        _categoryPreviewUrls[categoryName];
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              builder: (context) => WallpapersCategoryView(
                                categoryName: categoryName,
                                categoryUrlHq: categoryUrlHq,
                                categoryUrlMid: categoryUrlMid,
                                categoryUrlLow: categoryUrlLow,
                              ),
                              duration: const Duration(milliseconds: 600),
                            ),
                          );
                        },
                        child: SizedBox(
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              decoration: BoxDecoration(
                                image: previewImageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(previewImageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: previewImageUrl != null
                                    ? null
                                    : Theme.of(context).colorScheme.onPrimary,
                              ),
                              child: Container(
                                decoration: previewImageUrl != null
                                    ? BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.3),
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      )
                                    : null,
                                child: Center(
                                  child: Text(
                                    categoryName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: previewImageUrl != null
                                          ? Colors.white
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ));
                  },
                )),
          );
        });
  }

  /// Cleans up images that are no longer visible to free memory
  void _cleanupInvisibleImages(int firstVisibleIndex, int lastVisibleIndex) {
    final imagesToRemove = <String>[];

    for (final imageUrl in _preloadedImages) {
      // Extract index from the cached image URLs to determine if still visible
      bool isInVisibleRange = _visibleImages.contains(imageUrl);

      if (!isInVisibleRange) {
        imagesToRemove.add(imageUrl);
      }
    }

    // Only remove if cache is getting too large
    if (_preloadedImages.length > _maxCacheSize) {
      for (final imageUrl
          in imagesToRemove.take(_preloadedImages.length - _maxCacheSize)) {
        _preloadedImages.remove(imageUrl);
        // Evict from Flutter's image cache
        NetworkImage(imageUrl).evict();
      }
    }
  }

  /// Updates visible images set for cache management
  void _updateVisibleImages(
      WallpaperProvider provider, int firstVisibleIndex, int lastVisibleIndex) {
    _visibleImages.clear();

    for (int i = firstVisibleIndex;
        i <= lastVisibleIndex && i < provider.wallpaperNames.length;
        i++) {
      final String wallpaperName = provider.wallpaperNames[i].split(".")[0];
      final String wallpaperExtension =
          provider.wallpaperNames[i].split(".")[1];
      final String wallpaperCategory = provider.wallpaperCategories[i];
      final String wallpaperUrlLow =
          '${provider.baseUrlLow}/$wallpaperCategory/$wallpaperName.$wallpaperExtension';
      _visibleImages.add(wallpaperUrlLow);
    }
  }

  /// Preloads images for better user experience with memory optimization
  void _preloadImages(WallpaperProvider provider, int currentIndex) async {
    final startIndex = (currentIndex - _preloadBuffer ~/ 2)
        .clamp(0, provider.wallpaperNames.length - 1);
    final endIndex = (currentIndex + _preloadBuffer)
        .clamp(0, provider.wallpaperNames.length - 1);

    // Update visible images for cache management
    _updateVisibleImages(provider, startIndex, endIndex);

    for (int i = startIndex; i <= endIndex; i++) {
      if (i >= provider.wallpaperNames.length) break;

      final String wallpaperName = provider.wallpaperNames[i].split(".")[0];
      final String wallpaperExtension =
          provider.wallpaperNames[i].split(".")[1];
      final String wallpaperCategory = provider.wallpaperCategories[i];
      final String wallpaperUrlLow =
          '${provider.baseUrlLow}/$wallpaperCategory/$wallpaperName.$wallpaperExtension';

      if (!_preloadedImages.contains(wallpaperUrlLow)) {
        _preloadedImages.add(wallpaperUrlLow);
        try {
          await precacheImage(NetworkImage(wallpaperUrlLow), context);
        } catch (e) {
          // Silently handle preload errors
          debugPrint('Failed to preload image: $wallpaperUrlLow');
          _preloadedImages.remove(wallpaperUrlLow);
        }
      }
    }

    // Clean up cache periodically
    _cleanupInvisibleImages(startIndex, endIndex);
  }

  @override
  void dispose() {
    // Clear all cached images on dispose
    for (final imageUrl in _preloadedImages) {
      NetworkImage(imageUrl).evict();
    }
    _preloadedImages.clear();
    _visibleImages.clear();
    super.dispose();
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
              context.tr('wallpapers.title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchWallpapers,
        child: Consumer<WallpaperProvider>(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('common.connectionError'),
                          style: const TextStyle(fontSize: 25),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 34,
                        ),
                      ],
                    ),
                    TextButton(
                        onPressed: fetchWallpapers,
                        child: Text(context.tr('common.tryAgain')))
                  ],
                ),
              );
            } else if (provider.wallpaperNames.isEmpty) {
              return Center(child: Text(context.tr('wallpapers.fetching')));
            } else {
              // Start preloading images
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _preloadImages(provider, 0);
              });

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo is ScrollUpdateNotification) {
                    // Calculate current visible item index and preload ahead
                    final itemHeight = 200.0; // Approximate item height
                    final currentIndex =
                        (scrollInfo.metrics.pixels / itemHeight).floor();

                    // Only preload when scrolling stops or slows down to reduce memory pressure
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent ||
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.minScrollExtent ||
                        (scrollInfo.scrollDelta?.abs() ?? 0) < 5.0) {
                      _preloadImages(provider, currentIndex);
                    }
                  }
                  return false;
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 3 / 4,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.wallpaperNames.length,
                  itemBuilder: (context, index) {
                    final String wallpaperName =
                        provider.wallpaperNames[index].split(".")[0];
                    final String wallpaperExtension =
                        provider.wallpaperNames[index].split(".")[1];
                    final String wallpaperResolution =
                        provider.wallpaperResolutions[index];
                    final int wallpaperSize = provider.wallpaperSizes[index];
                    final String wallpaperCategory =
                        provider.wallpaperCategories[index];
                    final List wallpaperColors =
                        provider.wallpaperColors[index];
                    final String wallpaperUrlHq =
                        '${provider.baseUrlHq}/$wallpaperCategory/$wallpaperName.$wallpaperExtension';
                    final String wallpaperUrlMid =
                        '${provider.baseUrlMid}/$wallpaperCategory/$wallpaperName.$wallpaperExtension';
                    final String wallpaperUrlLow =
                        '${provider.baseUrlLow}/$wallpaperCategory/$wallpaperName.$wallpaperExtension';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            builder: (context) => WallpaperDetailsView(
                              wallpaperUrlHq: wallpaperUrlHq,
                              wallpaperUrlMid: wallpaperUrlMid,
                              wallpaperUrlLow: wallpaperUrlLow,
                              wallpaperName: wallpaperName,
                              wallpaperResolution: wallpaperResolution,
                              wallpaperSize: wallpaperSize,
                              wallpaperCategory: wallpaperCategory,
                              wallpaperColors: wallpaperColors.toString(),
                            ),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );
                      },
                      child: WallpaperCard(
                        wallpaperUrlHq: wallpaperUrlHq,
                        wallpaperUrlMid: wallpaperUrlMid,
                        wallpaperUrlLow: wallpaperUrlLow,
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
      floatingActionButton: Hero(
        tag: 'fab',
        child: FloatingActionButton(
          heroTag: null, // Disable internal Hero widget
          onPressed: _modalBottomSheetMenu,
          child: const Icon(Icons.menu_rounded),
        ),
      ),
    );
  }
}
