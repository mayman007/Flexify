import 'package:flexify/src/views/wallpaper_details_view.dart';
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
                          onPressed: fetchWallpapers,
                          child: const Text("Try Again"))
                    ],
                  ),
                );
              } else if (provider.wallpaperNames.isEmpty) {
                return const Center(child: Text('Fetching Wallpapers...'));
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
                    final wallpaperName =
                        provider.wallpaperNames[index].split(".")[0];
                    final wallpaperExtension =
                        provider.wallpaperNames[index].split(".")[1];
                    final wallpaperResolution =
                        provider.wallpaperResolutions[index];
                    final wallpaperSize = provider.wallpaperSizes[index];
                    final wallpaperCategory =
                        provider.wallpaperCategories[index];
                    final wallpaperColors = provider.wallpaperColors[index];
                    final wallpaperUrlHq =
                        '${provider.baseUrlHq}/$wallpaperCategory/$wallpaperName.$wallpaperExtension';
                    final wallpaperUrlMid =
                        '${provider.baseUrlMid}/$wallpaperCategory/$wallpaperName.$wallpaperExtension';
                    final uniqueKey = UniqueKey();

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            builder: (context) => WallpaperDetailsView(
                              wallpaperUrlHq: wallpaperUrlHq,
                              wallpaperUrlMid: wallpaperUrlMid,
                              wallpaperName: wallpaperName,
                              wallpaperResolution: wallpaperResolution,
                              wallpaperSize: wallpaperSize,
                              wallpaperCategory: wallpaperCategory,
                              wallpaperColors: wallpaperColors.toString(),
                              uniqueKey: uniqueKey,
                            ),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );
                      },
                      child: WallpaperCard(
                        wallpaperUrlHq: wallpaperUrlHq,
                        wallpaperUrlMid: wallpaperUrlMid,
                        uniqueKey: uniqueKey,
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        bottomNavigationBar: const MaterialNavBar(
          selectedIndex: 0,
        ),
      ),
    );
  }
}
