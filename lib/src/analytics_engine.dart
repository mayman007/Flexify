import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flexify/firebase_options.dart';

class AnalyticsEngine {
  static final _instance = FirebaseAnalytics.instance;

  static Future<void> init() {
    return Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  static void appOpened() async {
    return _instance.logAppOpen();
  }

  static void pageOpened(String pageName) async {
    return _instance.logScreenView(screenName: pageName);
  }

  static void wallpaperSet(String wallpaperName) async {
    return _instance.logEvent(
      name: "wallpaperSet",
      parameters: {
        "wallpaper_name": wallpaperName,
      },
    );
  }

  static void wallpaperSaved(String wallpaperName) async {
    return _instance.logEvent(
      name: "wallpaperSaved",
      parameters: {
        "wallpaper_name": wallpaperName,
      },
    );
  }

  static void widgetApplied(String widgetName) async {
    return _instance.logEvent(
      name: "widgetSet",
      parameters: {
        "widget_name": widgetName,
      },
    );
  }

  static void depthWallApplied(String depthWallName) async {
    return _instance.logEvent(
      name: "depthWallSet",
      parameters: {
        "depth_wall_name": depthWallName,
      },
    );
  }

  static void wallpaperFaved(String wallpaperName) async {
    return _instance.logEvent(
      name: "wallpaperFaved",
      parameters: {
        "wallpaper_name": wallpaperName,
      },
    );
  }

  static void widgetFaved(String widgetName) async {
    return _instance.logEvent(
      name: "widgetFaved",
      parameters: {
        "widget_name": widgetName,
      },
    );
  }

  static void depthWallFaved(String depthWallName) async {
    return _instance.logEvent(
      name: "depthWallFaved",
      parameters: {
        "depth_wall_name": depthWallName,
      },
    );
  }

  static void joinedTelegramChannal() async {
    return _instance.logEvent(
      name: "joinedTelegramChannal",
    );
  }

  static void clickedOnOpenSourceLink() async {
    return _instance.logEvent(
      name: "clickedOnOpenSourceLink",
    );
  }

  static void clickedOnDonationLink() async {
    return _instance.logEvent(
      name: "clickedOnDonationLink",
    );
  }
}
