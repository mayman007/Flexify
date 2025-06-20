import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/views/widget_details_view.dart';
import 'package:flexify/src/views/widgets_category_view.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
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
  Future fetchWidgets() async {
    final widgetProvider = Provider.of<WidgetProvider>(context, listen: false);
    widgetProvider.fetchWidgetData();
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
              return GridView.builder(
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
              );
            }
          },
        ),
      ),
      bottomNavigationBar: Hero(
        tag: 'bottom-nav-bar',
        child: const MaterialNavBar(
          selectedIndex: 2,
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
}
