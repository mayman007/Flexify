import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flexify/src/views/wallpapers_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings/settings_controller.dart';
import 'views/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color appColorSchemeSeed = Colors.blue;
  Color primaryContainerBackgroundColorDark =
      const Color.fromARGB(255, 32, 36, 39);
  Color? appBackgroundColorDark;
  bool isAndroid12OrHigherValue = true;

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
    String? darkThemePref = prefs.getString('darkTheme');
    await isAndroid12OrHigher();
    if (isAndroid12OrHigherValue == true) {
      schemeModePref ??= 'material_you';
    } else {
      schemeModePref ??= 'blue';
    }

    darkThemePref ??= 'Dim';
    if (schemeModePref == 'material_you') {
      setState(() {
        appColorSchemeSeed = const Color.fromARGB(777, 777, 777, 777);
      });
    } else if (schemeModePref == 'blue') {
      setState(() {
        appColorSchemeSeed = Colors.blue;

        appBackgroundColorDark = darkThemePref == 'Dim'
            ? const Color.fromARGB(255, 26, 29, 31)
            : Colors.black;
        primaryContainerBackgroundColorDark = darkThemePref == 'Dim'
            ? const Color.fromARGB(255, 32, 36, 39)
            : const Color.fromARGB(255, 16, 16, 20);
      });
    } else if (schemeModePref == 'green') {
      setState(() {
        appColorSchemeSeed = Colors.green;

        appBackgroundColorDark = darkThemePref == 'Dim'
            ? const Color.fromARGB(255, 18, 23, 19)
            : Colors.black;
        primaryContainerBackgroundColorDark = darkThemePref == 'Dim'
            ? const Color.fromARGB(255, 29, 37, 29)
            : const Color.fromARGB(255, 16, 20, 16);
      });
    } else if (schemeModePref == 'purble') {
      setState(() {
        appColorSchemeSeed = Colors.purple;

        appBackgroundColorDark = darkThemePref == 'Dim'
            ? const Color.fromARGB(255, 31, 26, 32)
            : Colors.black;
        primaryContainerBackgroundColorDark = darkThemePref == 'Dim'
            ? const Color.fromARGB(255, 37, 29, 36)
            : const Color.fromARGB(255, 20, 16, 19);
      });
    } else if (schemeModePref == 'red') {
      setState(() {
        appColorSchemeSeed = Colors.red;

        appBackgroundColorDark = darkThemePref == 'Dim'
            ? const Color.fromARGB(255, 32, 26, 26)
            : Colors.black;
        primaryContainerBackgroundColorDark = darkThemePref == 'Dim'
            ? const Color.fromARGB(255, 45, 35, 35)
            : const Color.fromARGB(255, 20, 16, 16);
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
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              // Providing a restorationScopeId allows the Navigator built by the
              // MaterialApp to restore the navigation stack when a user leaves and
              // returns to the app after it has been killed while running in the
              // background.
              restorationScopeId: 'app',

              // Provide the generated AppLocalizations to the MaterialApp. This
              // allows descendant Widgets to display the correct translations
              // depending on the user's locale.
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English, no country code
              ],

              // Use AppLocalizations to configure the correct application title
              // depending on the user's locale.
              //
              // The appTitle is defined in .arb files found in the localization
              // directory.
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context)!.appTitle,

              // Define a light and dark color theme. Then, read the user's
              // preferred ThemeMode (light, dark, or system default) from the
              // SettingsController to display the correct theme.
              theme:
                  appColorSchemeSeed == const Color.fromARGB(777, 777, 777, 777)
                      ? ThemeData(
                          brightness: Brightness.light,
                          colorScheme: lightColorScheme,
                        )
                      : ThemeData(
                          brightness: Brightness.light,
                          colorSchemeSeed: appColorSchemeSeed,
                        ),
              darkTheme:
                  appColorSchemeSeed == const Color.fromARGB(777, 777, 777, 777)
                      ? ThemeData(
                          brightness: Brightness.dark,
                          colorScheme: darkColorScheme,
                        )
                      : ThemeData(
                          brightness: Brightness.dark,
                          colorSchemeSeed: appColorSchemeSeed,
                        ),
              themeMode: widget.settingsController.themeMode,

              // Define a function to handle named routes in order to support
              // Flutter web url navigation and deep linking.
              onGenerateRoute: (RouteSettings routeSettings) {
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) {
                    switch (routeSettings.name) {
                      case SettingsView.routeName:
                        return SettingsView(
                            controller: widget.settingsController);
                      case WallpapersView.routeName:
                      default:
                        return WallpapersView(
                            settingsController: widget.settingsController);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
