import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/views/depthwall_details_view.dart';
import 'package:flexify/src/views/wallpaper_details_view.dart';
import 'package:flexify/src/views/widget_details_view.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  static const routeName = '/favorites';

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  DatabaseHelper sqlDb = DatabaseHelper();
  List favedWalls = [];
  List favedWidgets = [];
  List favedDepthWall = [];

  Future fetchFavedWallpapers() async {
    setState(() {
      favedWalls = [];
    });
    var table = await sqlDb.selectData("SELECT * FROM 'wallfavs'");
    for (var row in table) {
      setState(() {
        favedWalls.add(row);
      });
    }
  }

  Future fetchFavedWidgets() async {
    setState(() {
      favedWidgets = [];
    });
    var table = await sqlDb.selectData("SELECT * FROM 'widgetfavs'");
    for (var row in table) {
      setState(() {
        favedWidgets.add(row);
      });
    }
  }

  Future fetchFavedDepthWalls() async {
    setState(() {
      favedDepthWall = [];
    });
    var table = await sqlDb.selectData("SELECT * FROM 'lockscreenfavs'");
    for (var row in table) {
      setState(() {
        favedDepthWall.add(row);
      });
    }
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Favorites View");
    fetchFavedWallpapers();
    fetchFavedWidgets();
    fetchFavedDepthWalls();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Favorites",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: <Widget>[
              Tab(
                text: 'Wallpapers',
                icon: Icon(Icons.wallpaper_rounded),
              ),
              Tab(
                text: 'Widgets',
                icon: Icon(Icons.widgets_rounded),
              ),
              Tab(
                text: 'Depth Walls',
                icon: Icon(Icons.photo_library_rounded),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              onRefresh: fetchFavedWallpapers,
              child: favedWalls.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '(˵•ヘ•˵)',
                                style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 45,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'No Favorites Yet',
                                style: TextStyle(
                                  fontSize: 21,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 3 / 4,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: favedWalls.length,
                      itemBuilder: (context, index) {
                        final String wallpaperUrlHq =
                            favedWalls[index]['wallurlhq'];
                        final String wallpaperUrlMid =
                            favedWalls[index]['wallurlmid'];
                        final String wallpaperUrlLow =
                            favedWalls[index]['wallurllow'];
                        final String wallpaperName =
                            favedWalls[index]['wallname'];
                        // final wallpaperAuthor = favedWalls[index]['wallauthor'];
                        final String wallpaperResolution =
                            favedWalls[index]['wallresolution'];
                        final int wallpaperSize = favedWalls[index]['wallsize'];
                        final String wallpaperCategory =
                            favedWalls[index]['wallcategory'];
                        final String wallpaperColors =
                            favedWalls[index]['wallcolors'];

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
                                  wallpaperColors: wallpaperColors,
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
            ),
            RefreshIndicator(
              onRefresh: fetchFavedWidgets,
              child: favedWidgets.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '(˵•ヘ•˵)',
                                style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 45,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'No Favorites Yet',
                                style: TextStyle(
                                  fontSize: 21,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 3 / 4,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: favedWidgets.length,
                      itemBuilder: (context, index) {
                        final String widgetUrl =
                            favedWidgets[index]['widgeturl'];
                        final String widgetThumbnailUrl =
                            widgetUrl.replaceAll(".kwgt", ".png");
                        final String widgetName =
                            favedWidgets[index]['widgetname'];
                        // final favedWidgetsAuthor = favedWidgets[index]['wallauthor'];
                        final String widgetCategory =
                            favedWidgets[index]['widgetcategory'];

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
            ),
            RefreshIndicator(
              onRefresh: fetchFavedDepthWalls,
              child: favedDepthWall.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '(˵•ヘ•˵)',
                                style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontSize: 45,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'No Favorites Yet',
                                style: TextStyle(
                                  fontSize: 21,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 3 / 4,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: favedDepthWall.length,
                      itemBuilder: (context, index) {
                        final String depthWallUrl =
                            favedDepthWall[index]['lockscreenurl'];
                        final String depthWallThumbnailUrl =
                            depthWallUrl.replaceAll(".klwp", ".png");
                        final String depthWallName =
                            favedDepthWall[index]['lockscreenname'];

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
            ),
          ],
        ),
        bottomNavigationBar: const MaterialNavBar(
          selectedIndex: 3,
        ),
      ),
    );
  }
}
