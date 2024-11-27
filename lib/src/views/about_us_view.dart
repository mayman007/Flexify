import 'package:flexify/src/analytics_engine.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
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
              const Text(
                "Flexify",
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
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Polish your phone with Flexify's amazing set of wallpapers and widgets.",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    "Support Us",
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
                            text: "Flexify is %100 free and ",
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
                            text: "Open Source",
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
                            text:
                                ". However, you can show us that you care by making a ",
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
                            text: "Donation",
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    "Credits",
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Developer: ",
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
                                  text: "Designer: ",
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
              RichText(
                text: TextSpan(
                  text: "Privacy Policy",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Oduda",
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await launchUrl(Uri.parse(
                          "https://flexify-privacy-policy.pages.dev"));
                    },
                ),
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
