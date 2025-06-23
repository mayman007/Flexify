import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flexify/firebase_options.dart';

/// A wrapper class for Firebase Analytics to log various user events.
class AnalyticsEngine {
  static final _instance = FirebaseAnalytics.instance;

  /// Initializes the Firebase app.
  static Future<void> init() {
    return Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  /// Logs an 'app_open' event.
  static void appOpened() async {
    return _instance.logAppOpen();
  }

  /// Logs a 'screen_view' event.
  static void pageOpened(String pageName) async {
    return _instance.logScreenView(screenName: pageName);
  }

  /// Logs an event when a wallpaper is set.
  static void wallpaperSet(String wallpaperName) async {
    return _instance.logEvent(
      name: "wallpaperSet",
      parameters: {
        "wallpaper_name": wallpaperName,
      },
    );
  }

  /// Logs an event when a wallpaper is saved to the gallery.
  static void wallpaperSaved(String wallpaperName) async {
    return _instance.logEvent(
      name: "wallpaperSaved",
      parameters: {
        "wallpaper_name": wallpaperName,
      },
    );
  }

  /// Logs an event when a widget is applied.
  static void widgetApplied(String widgetName) async {
    return _instance.logEvent(
      name: "widgetSet",
      parameters: {
        "widget_name": widgetName,
      },
    );
  }

  /// Logs an event when a depth wallpaper is applied.
  static void depthWallApplied(String depthWallName) async {
    return _instance.logEvent(
      name: "depthWallSet",
      parameters: {
        "depth_wall_name": depthWallName,
      },
    );
  }

  /// Logs an event when a wallpaper is favorited.
  static void wallpaperFaved(String wallpaperName) async {
    return _instance.logEvent(
      name: "wallpaperFaved",
      parameters: {
        "wallpaper_name": wallpaperName,
      },
    );
  }

  /// Logs an event when a widget is favorited.
  static void widgetFaved(String widgetName) async {
    return _instance.logEvent(
      name: "widgetFaved",
      parameters: {
        "widget_name": widgetName,
      },
    );
  }

  /// Logs an event when a depth wallpaper is favorited.
  static void depthWallFaved(String depthWallName) async {
    return _instance.logEvent(
      name: "depthWallFaved",
      parameters: {
        "depth_wall_name": depthWallName,
      },
    );
  }

  /// Logs an event when the user joins the Telegram channel.
  static void joinedTelegramChannal() async {
    return _instance.logEvent(
      name: "joinedTelegramChannal",
    );
  }

  /// Logs an event when the user clicks the open-source link.
  static void clickedOnOpenSourceLink() async {
    return _instance.logEvent(
      name: "clickedOnOpenSourceLink",
    );
  }

  /// Logs an event when the user clicks the donation link.
  static void clickedOnDonationLink() async {
    return _instance.logEvent(
      name: "clickedOnDonationLink",
    );
  }

  /// Logs an event when the user clicks the donation link.
  static void sharedApp() async {
    return _instance.logEvent(
      name: "sharedApp",
    );
  }
}
