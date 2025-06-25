import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/provider/widget_category_provider.dart';
import 'package:flexify/src/views/widget_details_view.dart';
import 'package:flexify/src/utils/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class WidgetsCategoryView extends StatefulWidget {
  final String categoryName;
  final String categoryUrl;

  const WidgetsCategoryView(
      {super.key, required this.categoryName, required this.categoryUrl});

  @override
  State<WidgetsCategoryView> createState() => _WidgetsCategoryViewState();
}

class _WidgetsCategoryViewState extends State<WidgetsCategoryView> {
  /// Set to track which images have been preloaded
  final Set<String> _preloadedImages = {};

  /// Set to track currently visible images
  final Set<String> _visibleImages = {};

  /// Number of images to preload ahead of viewport (reduced for memory optimization)
  static const int _preloadBuffer = 6;

  /// Maximum number of images to keep in cache
  static const int _maxCacheSize = 20;

  Future fetchWidgets() async {
    final widgetProvider =
        Provider.of<WidgetCategoryProvider>(context, listen: false);
    widgetProvider.fetchWidgetCategoryData(widget.categoryUrl);
  }

  /// Cleans up images that are no longer visible to free memory
  void _cleanupInvisibleImages(int firstVisibleIndex, int lastVisibleIndex) {
    final imagesToRemove = <String>[];

    for (final imageUrl in _preloadedImages) {
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
        NetworkImage(imageUrl).evict();
      }
    }
  }

  /// Updates visible images set for cache management
  void _updateVisibleImages(WidgetCategoryProvider provider,
      int firstVisibleIndex, int lastVisibleIndex) {
    _visibleImages.clear();

    for (int i = firstVisibleIndex;
        i <= lastVisibleIndex && i < provider.widgetNames.length;
        i++) {
      final String widgetName = provider.widgetNames[i].split(".")[0];
      final String widgetThumbnailUrl = '${widget.categoryUrl}/$widgetName.png';
      _visibleImages.add(widgetThumbnailUrl);
    }
  }

  /// Preloads widget thumbnail images for better user experience with memory optimization
  void _preloadImages(WidgetCategoryProvider provider, int currentIndex) async {
    final startIndex = (currentIndex - _preloadBuffer ~/ 2)
        .clamp(0, provider.widgetNames.length - 1);
    final endIndex = (currentIndex + _preloadBuffer)
        .clamp(0, provider.widgetNames.length - 1);

    // Update visible images for cache management
    _updateVisibleImages(provider, startIndex, endIndex);

    for (int i = startIndex; i <= endIndex; i++) {
      if (i >= provider.widgetNames.length) break;

      final String widgetName = provider.widgetNames[i].split(".")[0];
      final String widgetThumbnailUrl = '${widget.categoryUrl}/$widgetName.png';

      if (!_preloadedImages.contains(widgetThumbnailUrl)) {
        _preloadedImages.add(widgetThumbnailUrl);
        try {
          await precacheImage(NetworkImage(widgetThumbnailUrl), context);
        } catch (e) {
          debugPrint('Failed to preload widget image: $widgetThumbnailUrl');
          _preloadedImages.remove(widgetThumbnailUrl);
        }
      }
    }

    // Clean up cache periodically
    _cleanupInvisibleImages(startIndex, endIndex);
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Widgets Category View");
    fetchWidgets();
    super.initState();
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
              context.tr('widgets.categoryTitle',
                  namedArgs: {'category': widget.categoryName}),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchWidgets,
        child: Consumer<WidgetCategoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '( ˃̣̣̥⌓˂̣̣̥)',
                      style: TextStyle(
                        fontSize: 55,
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
                        onPressed: fetchWidgets,
                        child: Text(context.tr('common.tryAgain')))
                  ],
                ),
              );
            } else if (provider.widgetNames.isEmpty) {
              return Center(child: Text(context.tr('widgets.fetching')));
            } else {
              // Start preloading images
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _preloadImages(provider, 0);
              });

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo is ScrollUpdateNotification) {
                    // Calculate current visible item index and preload ahead
                    final itemHeight = 240.0; // Approximate item height
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
                    childAspectRatio: 2 / 4,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.widgetNames.length,
                  itemBuilder: (context, index) {
                    final String widgetName =
                        provider.widgetNames[index].split(".")[0];
                    final String widgetExtension =
                        provider.widgetNames[index].split(".")[1];
                    final String widgetCategory =
                        provider.widgetCategories[index];
                    final String widgetUrl =
                        '${widget.categoryUrl}/$widgetName.$widgetExtension';
                    final String widgetThumbnailUrl =
                        '${widget.categoryUrl}/$widgetName.png';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            builder: (context) => WidgetDetailsView(
                              widgetUrl: widgetUrl,
                              widgetThumbnailUrl: widgetThumbnailUrl,
                              widgetName: widgetName,
                              widgetCategory: widgetCategory,
                            ),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );
                      },
                      child: WallpaperCard(
                        wallpaperUrlHq: widgetThumbnailUrl,
                        wallpaperUrlMid: widgetThumbnailUrl,
                        wallpaperUrlLow: widgetThumbnailUrl,
                        isWallpaper: false,
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
