import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/provider/widget_category_provider.dart';
import 'package:flexify/src/views/widget_details_view.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
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

  /// Number of images to preload ahead of viewport
  static const int _preloadBuffer = 15;

  Future fetchWidgets() async {
    final widgetProvider =
        Provider.of<WidgetCategoryProvider>(context, listen: false);
    widgetProvider.fetchWidgetCategoryData(widget.categoryUrl);
  }

  /// Preloads widget thumbnail images for better user experience
  void _preloadImages(WidgetCategoryProvider provider, int currentIndex) async {
    final startIndex = currentIndex;
    final endIndex = (currentIndex + _preloadBuffer)
        .clamp(0, provider.widgetNames.length - 1);

    for (int i = startIndex; i <= endIndex; i++) {
      if (i >= provider.widgetNames.length) break;

      final String widgetName = provider.widgetNames[i].split(".")[0];
      final String widgetThumbnailUrl = '${widget.categoryUrl}/$widgetName.png';

      if (!_preloadedImages.contains(widgetThumbnailUrl)) {
        _preloadedImages.add(widgetThumbnailUrl);
        try {
          await precacheImage(NetworkImage(widgetThumbnailUrl), context);
        } catch (e) {
          // Silently handle preload errors
          debugPrint('Failed to preload widget image: $widgetThumbnailUrl');
        }
      }
    }
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Widgets Category View");
    fetchWidgets();
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
