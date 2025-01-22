import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/provider/depthwall_provider.dart';
import 'package:flexify/src/provider/widget_category_provider.dart';
import 'package:flexify/src/provider/widget_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/provider/wallpaper_provider.dart';
import 'src/provider/wallpaper_category_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init analytics
  await AnalyticsEngine.init();
  AnalyticsEngine.appOpened;

  // Init db
  DatabaseHelper sqlDb = DatabaseHelper();
  await sqlDb.initialDb();

  runApp(
    // Init provider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
        ChangeNotifierProvider(create: (_) => WallpaperCategoryProvider()),
        ChangeNotifierProvider(create: (_) => WidgetProvider()),
        ChangeNotifierProvider(create: (_) => WidgetCategoryProvider()),
        ChangeNotifierProvider(create: (_) => DepthWallProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
