import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/provider/lockscreen_provider.dart';
import 'package:flexify/src/views/lockscreen_details_view.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LockscreenView extends StatefulWidget {
  const LockscreenView({super.key});

  static const routeName = '/lockscreen';

  @override
  State<LockscreenView> createState() => _LockscreenViewState();
}

class _LockscreenViewState extends State<LockscreenView> {
  Future fetchLockscreens() async {
    final lockscreenProvider =
        Provider.of<LockscreenProvider>(context, listen: false);
    lockscreenProvider.fetchLockscreenData();
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Depth Wall View");
    final lockscreenProvider =
        Provider.of<LockscreenProvider>(context, listen: false);

    if (lockscreenProvider.lockscreenNames.isEmpty) {
      // Fetch widget names on screen load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchLockscreens();
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
        onRefresh: fetchLockscreens,
        child: Consumer<LockscreenProvider>(
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
                        onPressed: fetchLockscreens,
                        child: const Text("Try Again"))
                  ],
                ),
              );
            } else if (provider.lockscreenNames.isEmpty) {
              return const Center(child: Text('Fetching Lockscreen...'));
            } else {
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 2 / 4,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: provider.lockscreenNames.length,
                itemBuilder: (context, index) {
                  final String lockscreenName =
                      provider.lockscreenNames[index].split(".")[0];
                  final String lockscreenExtension =
                      provider.lockscreenNames[index].split(".")[1];
                  final String lockscreenUrl =
                      '${provider.baseUrl}/$lockscreenName.$lockscreenExtension';
                  final String lockscreenThumbnailUrl =
                      '${provider.baseUrl}/$lockscreenName.png';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(
                          builder: (context) => LockscreenDetailsView(
                            lockscreenUrl: lockscreenUrl,
                            lockscreenThumbnailUrl: lockscreenThumbnailUrl,
                            lockscreenName: lockscreenName,
                          ),
                          duration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    child: WallpaperCard(
                      wallpaperUrlHq: lockscreenThumbnailUrl,
                      wallpaperUrlMid: lockscreenThumbnailUrl,
                      wallpaperUrlLow: lockscreenThumbnailUrl,
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
