import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/provider/depthwall_provider.dart';
import 'package:flexify/src/provider/widget_category_provider.dart';
import 'package:flexify/src/provider/widget_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'src/app.dart';
import 'src/notifications/notifications.dart';
import 'src/provider/wallpaper_provider.dart';
import 'src/provider/wallpaper_category_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) =>
    _firebaseMessagingBackgroundHandler(message);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Init analytics
  await AnalyticsEngine.init();
  AnalyticsEngine.appOpened;

  await EasyLocalization.ensureInitialized();

  // Register background handler early
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize your notification service
  await NotificationService.instance.initialize();

  // Init db
  DatabaseHelper sqlDb = DatabaseHelper();
  await sqlDb.initialDb();

  runApp(
    // Init provider
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WallpaperProvider()),
          ChangeNotifierProvider(create: (_) => WallpaperCategoryProvider()),
          ChangeNotifierProvider(create: (_) => WidgetProvider()),
          ChangeNotifierProvider(create: (_) => WidgetCategoryProvider()),
          ChangeNotifierProvider(create: (_) => DepthWallProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
