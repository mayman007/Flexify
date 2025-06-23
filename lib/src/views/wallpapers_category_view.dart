import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/provider/wallpaper_category_provider.dart';
import 'package:flexify/src/views/wallpaper_details_view.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

/// A view that displays wallpapers from a specific category.
class WallpapersCategoryView extends StatefulWidget {
  final String categoryName;
  final String categoryUrlHq;
  final String categoryUrlMid;
  final String categoryUrlLow;

  const WallpapersCategoryView({
    super.key,
    required this.categoryName,
    required this.categoryUrlHq,
    required this.categoryUrlMid,
    required this.categoryUrlLow,
  });

  static const routeName = '/wallpaperscategory';

  @override
  State<WallpapersCategoryView> createState() => _WallpapersCategoryViewState();
}

/// State for [WallpapersCategoryView].
class _WallpapersCategoryViewState extends State<WallpapersCategoryView> {
  /// Fetches wallpaper data for the current category from the [WallpaperCategoryProvider].
  Future fetchWallpapers() async {
    final wallpaperProvider =
        Provider.of<WallpaperCategoryProvider>(context, listen: false);
    wallpaperProvider.fetchWallpaperCategoryData(widget.categoryUrlHq);
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Wallpapers Category View");
    fetchWallpapers();
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
              context.tr('wallpapers.categoryTitle',
                  namedArgs: {'category': widget.categoryName}),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchWallpapers,
        child: Consumer<WallpaperCategoryProvider>(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('common.connectionError'),
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
                        onPressed: fetchWallpapers,
                        child: Text(context.tr('common.tryAgain')))
                  ],
                ),
              );
            } else if (provider.wallpaperNames.isEmpty) {
              return Center(child: Text(context.tr('wallpapers.fetching')));
            } else {
              return GridView.builder(
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
                  final List wallpaperColors = provider.wallpaperColors[index];
                  final String wallpaperUrlHq =
                      '${widget.categoryUrlHq}/$wallpaperName.$wallpaperExtension';
                  final String wallpaperUrlMid =
                      '${widget.categoryUrlMid}/$wallpaperName.$wallpaperExtension';
                  final String wallpaperUrlLow =
                      '${widget.categoryUrlLow}/$wallpaperName.$wallpaperExtension';

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
              );
            }
          },
        ),
      ),
    );
  }
}
