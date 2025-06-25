import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/views/widget_details_view.dart';
import 'package:flexify/src/views/widgets_category_view.dart';
import 'package:flexify/src/utils/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../provider/widget_provider.dart';

class WidgetsView extends StatefulWidget {
  const WidgetsView({super.key});

  static const routeName = '/widgets';

  @override
  State<WidgetsView> createState() => _WidgetsViewState();
}

class _WidgetsViewState extends State<WidgetsView> {
  /// Set to track which images have been preloaded
  final Set<String> _preloadedImages = {};

  /// Set to track currently visible images
  final Set<String> _visibleImages = {};

  /// Number of images to preload ahead of viewport (reduced for memory optimization)
  static const int _preloadBuffer = 6;

  /// Maximum number of images to keep in cache
  static const int _maxCacheSize = 20;

  Future fetchWidgets() async {
    final widgetProvider = Provider.of<WidgetProvider>(context, listen: false);
    widgetProvider.fetchWidgetData();
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
  void _updateVisibleImages(
      WidgetProvider provider, int firstVisibleIndex, int lastVisibleIndex) {
    _visibleImages.clear();

    for (int i = firstVisibleIndex;
        i <= lastVisibleIndex && i < provider.widgetNames.length;
        i++) {
      final String widgetName = provider.widgetNames[i].split(".")[0];
      final String widgetCategory = provider.widgetCategories[i];
      final String widgetThumbnailUrl =
          '${provider.baseUrl}/$widgetCategory/$widgetName.png';
      _visibleImages.add(widgetThumbnailUrl);
    }
  }

  /// Preloads widget thumbnail images for better user experience with memory optimization
  void _preloadImages(WidgetProvider provider, int currentIndex) async {
    final startIndex = (currentIndex - _preloadBuffer ~/ 2)
        .clamp(0, provider.widgetNames.length - 1);
    final endIndex = (currentIndex + _preloadBuffer)
        .clamp(0, provider.widgetNames.length - 1);

    // Update visible images for cache management
    _updateVisibleImages(provider, startIndex, endIndex);

    for (int i = startIndex; i <= endIndex; i++) {
      if (i >= provider.widgetNames.length) break;

      final String widgetName = provider.widgetNames[i].split(".")[0];
      final String widgetCategory = provider.widgetCategories[i];
      final String widgetThumbnailUrl =
          '${provider.baseUrl}/$widgetCategory/$widgetName.png';

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

  _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          final provider = Provider.of<WidgetProvider>(context, listen: false);
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
                    final String categoryUrl =
                        "${provider.baseUrl}/$categoryName";

                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              builder: (context) => WidgetsCategoryView(
                                categoryName: categoryName,
                                categoryUrl: categoryUrl,
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
                            color: Theme.of(context).colorScheme.onPrimary,
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              child: Center(
                                child: Text(
                                  categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
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

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Widgets View");
    final widgetProvider = Provider.of<WidgetProvider>(context, listen: false);

    if (widgetProvider.widgetNames.isEmpty) {
      // Fetch widget names on screen load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchWidgets();
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
              context.tr('widgets.title'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchWidgets,
        child: Consumer<WidgetProvider>(
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
                        '${provider.baseUrl}/$widgetCategory/$widgetName.$widgetExtension';
                    final String widgetThumbnailUrl =
                        '${provider.baseUrl}/$widgetCategory/$widgetName.png';

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
}
