import 'package:device_info_plus/device_info_plus.dart';
import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String colorSchemeValue = 'Material You';
  String themeValue = 'System Mode';
  bool isPureBlackEnabledValue = false;

  getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? scheme = prefs.getString('schemeMode');
    String? theme = prefs.getString('themeMode');
    bool? isPureBlackEnabled = prefs.getBool('isPureBlackEnabled');

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
    });
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
            const Text(
              'Themes',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            RadioListTile<String>(
              title: const Text('System'),
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
              title: const Text('Light'),
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
              title: const Text('Dark'),
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
            const Text(
              'Color Schemes',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            isAndroid12OrHigherValue
                ? RadioListTile<String>(
                    title: const Text('Material You'),
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
              title: const Text('Blue'),
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
              title: const Text('Green'),
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
              title: const Text('Purble'),
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
              title: const Text('Red'),
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

  @override
  void initState() {
    getPrefs();
    isAndroid12OrHigher();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'General Theme',
                    style: TextStyle(fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: showThemeDialog,
                    child: Text(themeValue == 'System Mode'
                        ? 'System'
                        : themeValue == 'Light Mode'
                            ? 'Light'
                            : 'Dark'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Color Scheme',
                    style: TextStyle(fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: showColorSchemesDialog,
                    child: Text(colorSchemeValue == 'Blue Scheme'
                        ? 'Blue'
                        : colorSchemeValue == 'Green Scheme'
                            ? 'Green'
                            : colorSchemeValue == 'Purble Scheme'
                                ? 'Purble'
                                : colorSchemeValue == 'Red Scheme'
                                    ? 'Red'
                                    : colorSchemeValue == 'Material You'
                                        ? 'Material You'
                                        : ''),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pure Black',
                    style: TextStyle(fontSize: 18),
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
            ],
          ),
        ),
        bottomNavigationBar: const MaterialNavBar(
          selectedIndex: 3,
        ));
  }
}
