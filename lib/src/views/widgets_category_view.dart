import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/provider/widget_category_provider.dart';
import 'package:flexify/src/views/widget_details_view.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WidgetsCategoryView extends StatefulWidget {
  final String categoryName;
  final String categoryUrl;

  const WidgetsCategoryView(
      {super.key, required this.categoryName, required this.categoryUrl});

  @override
  State<WidgetsCategoryView> createState() => _WidgetsCategoryViewState();
}

class _WidgetsCategoryViewState extends State<WidgetsCategoryView> {
  Future fetchWidgets() async {
    final widgetProvider =
        Provider.of<WidgetCategoryProvider>(context, listen: false);
    widgetProvider.fetchWidgetCategoryData(widget.categoryUrl);
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
      appBar: AppBar(
        title: Text(
          "${widget.categoryName} Widgets",
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        onPressed: fetchWidgets, child: const Text("Try Again"))
                  ],
                ),
              );
            } else if (provider.widgetNames.isEmpty) {
              return const Center(child: Text('Fetching Widgets...'));
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
                      isWallpaper: false,
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
