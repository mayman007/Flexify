import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/provider/widget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/provider/wallpaper_provider.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  WidgetsFlutterBinding.ensureInitialized();

  DatabaseHelper sqlDb = DatabaseHelper();
  await sqlDb.initialDb();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WallpaperProvider()),
        ChangeNotifierProvider(create: (_) => WidgetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
