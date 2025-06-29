import 'package:flexify/src/analytics_engine.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';

/// A view that displays information about the app, its creators, and relevant links.
class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  @override
  void initState() {
    AnalyticsEngine.pageOpened("About Us View");
    super.initState();
  }

  Future<void> _shareApp() async {
    const String playStoreUrl =
        "https://play.google.com/store/apps/details?id=com.maymanxineffable.flexify";
    const String shareText =
        "Polish your phone with Flexify's amazing set of wallpapers and widgets.";

    await SharePlus.instance.share(ShareParams(
        title: shareText,
        text: '$shareText\n\nDownload Flexify From Play Store: $playStoreUrl'));
    AnalyticsEngine.sharedApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('aboutUs.title'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/images/icon.png',
                fit: BoxFit.fitWidth,
                height: 150,
              ),
              Text(
                context.tr('appTitle'),
                style: TextStyle(
                  fontSize: 45,
                  fontFamily: "Oduda-Bold",
                  color: Color.fromARGB(255, 179, 179, 179),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    context.tr('aboutUs.description'),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    context.tr('aboutUs.supportUs'),
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Card(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: context.tr('aboutUs.freeAndOpenSource'),
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Oduda",
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context)
                                      .primaryTextTheme
                                      .bodyLarge!
                                      .color
                                  : Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: context.tr('aboutUs.openSource'),
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Oduda",
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              // decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launchUrl(Uri.parse(
                                    "https://github.com/mayman007/flexify"));
                                AnalyticsEngine.clickedOnOpenSourceLink();
                              },
                          ),
                          TextSpan(
                            text: context.tr('aboutUs.donationText'),
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Oduda",
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context)
                                      .primaryTextTheme
                                      .bodyLarge!
                                      .color
                                  : Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: context.tr('aboutUs.donation'),
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Oduda",
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              // decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launchUrl(
                                    Uri.parse("https://ko-fi.com/flexify"));
                                AnalyticsEngine.clickedOnDonationLink();
                              },
                          ),
                          TextSpan(
                            text: ".",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Oduda",
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyLarge!
                                  .color,
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    context.tr('aboutUs.credits'),
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Card(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: context.tr('aboutUs.developer'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Oduda",
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(context)
                                            .primaryTextTheme
                                            .bodyLarge!
                                            .color
                                        : Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: "Mayman",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Oduda",
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    // decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await launchUrl(Uri.parse(
                                          "https://github.com/mayman007"));
                                    },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: context.tr('aboutUs.designer'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Oduda",
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(context)
                                            .primaryTextTheme
                                            .bodyLarge!
                                            .color
                                        : Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: "Ineffable",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Oduda",
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    // decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await launchUrl(Uri.parse(
                                          "https://t.me/Ineffabletg"));
                                    },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _shareApp,
                    child: Text(
                      context.tr('aboutUs.shareApp'),
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Oduda",
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await launchUrl(Uri.parse(
                          "https://flexify-privacy-policy.pages.dev"));
                    },
                    child: Text(
                      context.tr('aboutUs.privacyPolicy'),
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Oduda",
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
