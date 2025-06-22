import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/views/about_us_view.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isAndroid12OrHigherValue = true;
  bool isNotificationPermissionGranted = true;
  String colorSchemeValue = 'Material You';
  String themeValue = 'System Mode';
  String languageValue = 'English';
  bool isPureBlackEnabledValue = false;
  bool isAmbientEffectEnabledValue = true;

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

  getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? scheme = prefs.getString('schemeMode');
    String? theme = prefs.getString('themeMode');
    bool? isPureBlackEnabled = prefs.getBool('isPureBlackEnabled');
    bool? isAmbientEffectEnabled = prefs.getBool('isAmbientEffectEnabled');

    setState(() {
      if (scheme == null || scheme == 'material_you') {
        if (isAndroid12OrHigherValue) {
          colorSchemeValue = 'Material You';
        } else {
          colorSchemeValue = 'Blue Scheme';
        }
      } else if (scheme == 'blue') {
        colorSchemeValue = 'Blue Scheme';
      } else if (scheme == 'green') {
        colorSchemeValue = 'Green Scheme';
      } else if (scheme == 'purble') {
        colorSchemeValue = 'Purble Scheme';
      } else if (scheme == 'red') {
        colorSchemeValue = 'Red Scheme';
      }
      if (theme == null || theme == 'system') {
        themeValue = 'System Mode';
      } else if (theme == 'light') {
        themeValue = 'Light Mode';
      } else if (theme == 'dark') {
        themeValue = 'Dark Mode';
      }

      if (isPureBlackEnabled == null || isPureBlackEnabled == false) {
        isPureBlackEnabledValue = false;
      } else if (isPureBlackEnabled == true) {
        isPureBlackEnabledValue = true;
      }

      if (isAmbientEffectEnabled == null || isAmbientEffectEnabled == true) {
        isAmbientEffectEnabledValue = true;
      } else {
        isAmbientEffectEnabledValue = false;
      }

      // Set language value based on current locale
      if (context.locale.languageCode == 'en') {
        languageValue = 'English';
      } else if (context.locale.languageCode == 'ar') {
        languageValue = 'Arabic';
      } else {
        languageValue = 'English'; // Default fallback
      }
    });
  }

  Future<void> showLanguageDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.language_rounded,
              size: 30,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              context.tr('settings.language'),
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: languageValue,
              onChanged: (value) async {
                context.setLocale(const Locale('en'));
                setState(() {
                  languageValue = 'English';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'Arabic',
              groupValue: languageValue,
              onChanged: (value) async {
                context.setLocale(const Locale('ar'));
                setState(() {
                  languageValue = 'Arabic';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        )));
      },
    );
  }

  Future<void> showThemeDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.color_lens_rounded,
              size: 30,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              context.tr('settings.themes'),
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            RadioListTile<String>(
              title: Text(context.tr('settings.system')),
              value: 'System Mode',
              groupValue: themeValue,
              onChanged: (value) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('themeMode', 'system');
                setState(() {
                  themeValue = 'System Mode';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(context.tr('settings.light')),
              value: 'Light Mode',
              groupValue: themeValue,
              onChanged: (value) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('themeMode', 'light');
                setState(() {
                  themeValue = 'Light Mode';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(context.tr('settings.dark')),
              value: 'Dark Mode',
              groupValue: themeValue,
              onChanged: (value) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('themeMode', 'dark');
                setState(() {
                  themeValue = 'Dark Mode';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            )
          ],
        )));
      },
    );
  }

  Future<void> showColorSchemesDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.color_lens_rounded,
              size: 30,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              context.tr('settings.colorScheme'),
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            isAndroid12OrHigherValue
                ? RadioListTile<String>(
                    title: Text(context.tr('settings.dynamic')),
                    value: 'Material You',
                    groupValue: colorSchemeValue,
                    onChanged: (value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('schemeMode', 'material_you');
                      setState(() {
                        colorSchemeValue = 'Material You';
                      });
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  )
                : const SizedBox(),
            RadioListTile<String>(
              title: Text(context.tr('settings.blue')),
              value: 'Blue Scheme',
              groupValue: colorSchemeValue,
              onChanged: (value) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('schemeMode', 'blue');
                setState(() {
                  colorSchemeValue = 'Blue Scheme';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(context.tr('settings.green')),
              value: 'Green Scheme',
              groupValue: colorSchemeValue,
              onChanged: (value) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('schemeMode', 'green');
                setState(() {
                  colorSchemeValue = 'Green Scheme';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(context.tr('settings.purple')),
              value: 'Purble Scheme',
              groupValue: colorSchemeValue,
              onChanged: (value) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('schemeMode', 'purble');
                setState(() {
                  colorSchemeValue = 'Purble Scheme';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(context.tr('settings.red')),
              value: 'Red Scheme',
              groupValue: colorSchemeValue,
              onChanged: (value) async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('schemeMode', 'red');
                setState(() {
                  colorSchemeValue = 'Red Scheme';
                });
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        )));
      },
    );
  }

  String cacheSize = '';

  Future getCacheSize() async {
    Directory tempDir = await getTemporaryDirectory();
    int tempDirSize = _getSize(tempDir);
    double tempDirSizeInMb = tempDirSize / 1024 / 1024;
    setState(() {
      cacheSize = tempDirSizeInMb.toStringAsFixed(2);
    });
  }

  int _getSize(FileSystemEntity file) {
    if (file is File) {
      return file.lengthSync();
    } else if (file is Directory) {
      int sum = 0;
      List<FileSystemEntity> children = file.listSync();
      for (FileSystemEntity child in children) {
        sum += _getSize(child);
      }
      return sum;
    }
    return 0;
  }

  Future<void> clearAppCache() async {
    try {
      // Get the temporary directory (cache directory)
      final Directory tempDir = await getTemporaryDirectory();

      // Check if the directory exists
      if (tempDir.existsSync()) {
        // Delete the directory and its contents
        tempDir.deleteSync(recursive: true);
        log("Cache cleared successfully!");
      } else {
        log("No cache found to clear.");
      }
    } catch (e) {
      log("Failed to clear cache: $e");
    }
    await getCacheSize();
  }

  showDeleteCacheDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            title: Text(context.tr('settings.deleteCacheTitle')),
            content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      context.tr('settings.deleteCacheConfirm'),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    )
                  ]),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(context.tr('settings.cancel')),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await clearAppCache();
                    },
                    child: Text(context.tr('settings.delete')),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> checkNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      setState(() {
        isNotificationPermissionGranted = status.isGranted;
      });
    }
  }

  Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      setState(() {
        isNotificationPermissionGranted = status.isGranted;
      });

      if (!status.isGranted) {
        // Show dialog to go to settings if permission is permanently denied
        if (status.isPermanentlyDenied) {
          _showPermissionDialog();
        }
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('settings.permissionRequired')),
          content: Text(
            context.tr('settings.notificationPermissionText'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('settings.cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text(context.tr('settings.openSettings')),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Settings View");
    getPrefs();
    isAndroid12OrHigher();
    getCacheSize();
    checkNotificationPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('settings.title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('settings.language'),
                  style: const TextStyle(fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: showLanguageDialog,
                  child: Text(languageValue == 'English'
                      ? 'English'
                      : languageValue == 'Arabic'
                          ? 'العربية'
                          : 'English'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('settings.generalTheme'),
                  style: const TextStyle(fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: showThemeDialog,
                  child: Text(themeValue == 'System Mode'
                      ? context.tr('settings.system')
                      : themeValue == 'Light Mode'
                          ? context.tr('settings.light')
                          : context.tr('settings.dark')),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('settings.colorScheme'),
                  style: const TextStyle(fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: showColorSchemesDialog,
                  child: Text(colorSchemeValue == 'Blue Scheme'
                      ? context.tr('settings.blue')
                      : colorSchemeValue == 'Green Scheme'
                          ? context.tr('settings.green')
                          : colorSchemeValue == 'Purble Scheme'
                              ? context.tr('settings.purple')
                              : colorSchemeValue == 'Red Scheme'
                                  ? context.tr('settings.red')
                                  : colorSchemeValue == 'Material You'
                                      ? context.tr('settings.dynamic')
                                      : ''),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('settings.pureBlack'),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  width: 10,
                ),
                Switch(
                  value: isPureBlackEnabledValue == true,
                  onChanged: (newValue) async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    bool isPureBlackEnabled;
                    if (newValue) {
                      isPureBlackEnabled = true;
                    } else {
                      isPureBlackEnabled = false;
                    }
                    await prefs.setBool(
                        'isPureBlackEnabled', isPureBlackEnabled);
                    setState(() {
                      isPureBlackEnabledValue = isPureBlackEnabled;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('settings.ambientEffect'),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  width: 10,
                ),
                Switch(
                  value: isAmbientEffectEnabledValue == true,
                  onChanged: (newValue) async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    bool isAmbientEffectEnabled;
                    if (newValue) {
                      isAmbientEffectEnabled = true;
                    } else {
                      isAmbientEffectEnabled = false;
                    }
                    await prefs.setBool(
                        'isAmbientEffectEnabled', isAmbientEffectEnabled);
                    setState(() {
                      isAmbientEffectEnabledValue = isAmbientEffectEnabled;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('settings.deleteCache',
                      namedArgs: {'size': cacheSize}),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await showDeleteCacheDialog(context);
                  },
                  child: Text(context.tr('settings.delete')),
                )
              ],
            ),
            !isNotificationPermissionGranted
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('settings.enableNotifications'),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await requestNotificationPermission();
                        },
                        child: Text(context.tr('settings.enable')),
                      )
                    ],
                  )
                : const SizedBox(),
            InkWell(
              onTap: () async {
                await launchUrl(Uri.parse("https://t.me/Flexify_updates"));
                AnalyticsEngine.joinedTelegramChannal();
              },
              child: Column(
                children: [
                  SizedBox(
                    height: 13,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.telegram_rounded,
                        size: 28,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        context.tr('settings.joinTelegramChannel'),
                        style: TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 13,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageRoute(
                    builder: (context) => const AboutUsView(),
                    duration: const Duration(milliseconds: 600),
                  ),
                );
              },
              child: Column(
                children: [
                  SizedBox(
                    height: 13,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 28,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        context.tr('settings.aboutUs'),
                        style: TextStyle(fontSize: 22),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 13,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
