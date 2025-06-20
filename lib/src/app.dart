import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/src/views/wallpapers_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color? appColorSchemeSeed = Colors.blue;
  ThemeMode? appThemeMode = ThemeMode.system;
  bool isAndroid12OrHigherValue = true;
  bool isPureBlackEnabled = false;

  Future isAndroid12OrHigher() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      setState(() {
        isAndroid12OrHigherValue = true;
      });
    } else {
      setState(() {
        isAndroid12OrHigherValue = false;
      });
    }
  }

  Future getPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? schemeModePref = prefs.getString('schemeMode');
    String? themeModePref = prefs.getString('themeMode');
    bool? isPureBlackEnabledPref = prefs.getBool('isPureBlackEnabled');
    await isAndroid12OrHigher();
    if (isAndroid12OrHigherValue) {
      schemeModePref ??= 'material_you';
    } else {
      schemeModePref ??= 'blue';
    }

    themeModePref ??= 'system';

    isPureBlackEnabledPref ??= false;

    if (schemeModePref == 'material_you') {
      setState(() {
        appColorSchemeSeed = null;
      });
    } else if (schemeModePref == 'blue') {
      setState(() {
        appColorSchemeSeed = Colors.blue;
      });
    } else if (schemeModePref == 'green') {
      setState(() {
        appColorSchemeSeed = Colors.green;
      });
    } else if (schemeModePref == 'purble') {
      setState(() {
        appColorSchemeSeed = Colors.purple;
      });
    } else if (schemeModePref == 'red') {
      setState(() {
        appColorSchemeSeed = Colors.red;
      });
    }

    if (themeModePref == 'system') {
      setState(() {
        appThemeMode = ThemeMode.system;
      });
    } else if (themeModePref == 'light') {
      setState(() {
        appThemeMode = ThemeMode.light;
      });
    } else if (themeModePref == 'dark') {
      setState(() {
        appThemeMode = ThemeMode.dark;
      });
    }

    if (isPureBlackEnabledPref) {
      setState(() {
        isPureBlackEnabled = true;
      });
    } else {
      setState(() {
        isPureBlackEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getPref();

    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            fontFamily: "Oduda",
            brightness: Brightness.light,
            colorSchemeSeed: appColorSchemeSeed == null
                ? lightColorScheme!.primary // If Material You is used
                : appColorSchemeSeed,
          ),
          darkTheme: ThemeData(
            fontFamily: "Oduda",
            colorScheme: ColorScheme.fromSeed(
              seedColor: appColorSchemeSeed == null
                  ? darkColorScheme!.primary // If Material You is used
                  : appColorSchemeSeed!,
              brightness: Brightness.dark,
            ).copyWith(
              surface: isPureBlackEnabled ? Colors.black : null,
            ),
          ),
          themeMode: appThemeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return const SettingsView();
                  case WallpapersView.routeName:
                  default:
                    return const WallpapersView();
                }
              },
            );
          },
        );
      },
    );
  }
}
