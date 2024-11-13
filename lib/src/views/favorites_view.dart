import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/views/wallpaper_details_view.dart';
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

  @override
  void initState() {
    fetchFavedWallpapers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorites",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 3 / 4,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: favedWalls.length,
                itemBuilder: (context, index) {
                  final wallpaperUrl = favedWalls[index]['wallurl'];
                  final wallpaperName = favedWalls[index]['wallname'];
                  final wallpaperAuthor = favedWalls[index]['wallauthor'];
                  final uniqueKey = UniqueKey();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(
                          builder: (context) => WallpaperDetailsView(
                            wallpaperUrl: wallpaperUrl,
                            wallpaperName: wallpaperName,
                            wallpaperAuthor: wallpaperAuthor,
                            uniqueKey: uniqueKey,
                          ),
                          duration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    child: WallpaperCard(
                      wallpaperUrl: wallpaperUrl,
                      uniqueKey: uniqueKey,
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const MaterialNavBar(
        selectedIndex: 2,
      ),
    );
  }
}
