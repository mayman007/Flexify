import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/views/wallpaper_details_view.dart';
import 'package:flexify/src/views/wallpapers_category_view.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future fetchWallpapers() async {
    final wallpaperProvider =
        Provider.of<WallpaperProvider>(context, listen: false);
    wallpaperProvider.fetchWallpaperData();
  }

  _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          final provider =
              Provider.of<WallpaperProvider>(context, listen: false);
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Hero(
            tag: 'app-bar',
            child: AppBar(
              title: Text(
                context.tr('wallpapers.title'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                );
              }
            },
          ),
        ),
        bottomNavigationBar: Hero(
          tag: 'bottom-nav-bar',
          child: const MaterialNavBar(
            selectedIndex: 0,
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
      ),
    );
  }
}
