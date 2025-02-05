import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/provider/depthwall_provider.dart';
import 'package:flexify/src/views/depthwall_details_view.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DepthWallView extends StatefulWidget {
  const DepthWallView({super.key});

  static const routeName = '/depthWall';

  @override
  State<DepthWallView> createState() => _DepthWallViewState();
}

class _DepthWallViewState extends State<DepthWallView> {
  Future fetchDepthWalls() async {
    final depthWallProvider =
        Provider.of<DepthWallProvider>(context, listen: false);
    depthWallProvider.fetchDepthWallData();
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
      appBar: AppBar(
        title: const Text(
          "Depth Wallpapers",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                        onPressed: fetchDepthWalls,
                        child: const Text("Try Again"))
                  ],
                ),
              );
            } else if (provider.depthWallNames.isEmpty) {
              return const Center(child: Text('Fetching DepthWall...'));
            } else {
              return GridView.builder(
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
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const MaterialNavBar(
        selectedIndex: 1,
      ),
    );
  }
}
