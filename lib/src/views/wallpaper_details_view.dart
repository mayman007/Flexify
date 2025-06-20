import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:dio/dio.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/views/wallpaper_fullscreen_view.dart';
import 'package:flexify/src/widgets/color_container.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:easy_localization/easy_localization.dart';

class WallpaperDetailsView extends StatefulWidget {
  final String wallpaperUrlHq;
  final String wallpaperUrlMid;
  final String wallpaperUrlLow;
  final String wallpaperName;
  final String wallpaperResolution;
  final int wallpaperSize;
  final String wallpaperCategory;
  final String wallpaperColors;

  static const routeName = '/wallpapers_details';

  const WallpaperDetailsView({
    super.key,
    required this.wallpaperUrlHq,
    required this.wallpaperUrlMid,
    required this.wallpaperUrlLow,
    required this.wallpaperName,
    required this.wallpaperResolution,
    required this.wallpaperSize,
    required this.wallpaperCategory,
    required this.wallpaperColors,
  });

  @override
  State<WallpaperDetailsView> createState() => _WallpaperDetailsViewState();
}

class _WallpaperDetailsViewState extends State<WallpaperDetailsView> {
  DatabaseHelper sqlDb = DatabaseHelper();
  bool saveImageCoolDown = false;

  saveNetworkImage() async {
    if (saveImageCoolDown) {
      showToast(
        context.tr('wallpaperDetails.saveWaitMessage'),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 500),
        // ignore: use_build_context_synchronously
        context: context,
      );
    } else {
      showLoaderDialog(context);
      setState(() {
        saveImageCoolDown = true;
      });
      var response = await Dio().get(widget.wallpaperUrlHq,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "Flexify_${widget.wallpaperName}",
      );
      Navigator.pop(context);
      showToast(
        context.tr('wallpaperDetails.wallpaperSaved'),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 500),
        // ignore: use_build_context_synchronously
        context: context,
      );
      log(result.toString());
      await Future.delayed(const Duration(seconds: 10));
      setState(() {
        saveImageCoolDown = false;
      });
      AnalyticsEngine.wallpaperSaved(widget.wallpaperName);
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.fromLTRB(20, 15, 0, 10),
              child: Text(context.tr('wallpaperDetails.fetchingWallpaper'))),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> setAsWallpaper() async {
    showLoaderDialog(context); // Show loading dialog

    try {
      if (wallLocation < 4) {
        final file = await DefaultCacheManager()
            .getSingleFile(widget.wallpaperUrlHq, key: widget.wallpaperUrlHq);
        Navigator.pop(context);
        await WallpaperManagerPlus().setWallpaper(file, wallLocation);
      } else {
        // Make file path
        var tempDir = await getTemporaryDirectory();
        String fullPath = "${tempDir.path}/${widget.wallpaperName}.png";

        // Download file
        Response response = await Dio().get(
          widget.wallpaperUrlHq,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ),
        );
        Navigator.pop(context);

        // Write file
        File file = File(fullPath);
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();

        log('File path: ${file.path}');
        log('File size: ${await file.length()} bytes');

        // Create a content URI using FileProvider
        const String authority = "com.maymanxineffable.flexify.fileprovider";
        // final String filePath = file.path;
        final Uri contentUri = Uri.parse(
            "content://$authority/cache_files/${Uri.encodeComponent(file.uri.pathSegments.last)}");

        // Use the android_intent_plus package to send the intent
        final intent = AndroidIntent(
          action: 'android.intent.action.ATTACH_DATA',
          type: 'image/*',
          data: contentUri.toString(),
          flags: [
            Flag.FLAG_GRANT_READ_URI_PERMISSION,
          ],
        );

        // Launch the intent
        await intent.launch();
      }
    } catch (e) {
      log("Error setting wallpaper: $e");
      showToast(
        context.tr('wallpaperDetails.settingWallpaperFailed'),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        // ignore: use_build_context_synchronously
        context: context,
      );
    }
    setState(() {
      wallLocation = 0;
    });
    log("wallLocation $wallLocation");
    DefaultCacheManager().removeFile(widget.wallpaperUrlHq);
    AnalyticsEngine.wallpaperSet(widget.wallpaperName);
  }

  int wallLocation = 0;

  Future<void> showSetWallpaperDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              const Icon(
                Icons.photo_size_select_actual_rounded,
                size: 30,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                context.tr('wallpaperDetails.setAsWallpaper'),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              RadioListTile<String>(
                title: Text(context.tr('wallpaperDetails.homeScreen')),
                value: WallpaperManagerPlus.homeScreen.toString(),
                groupValue: null,
                onChanged: (value) async {
                  setState(() {
                    wallLocation = WallpaperManagerPlus.homeScreen;
                  });
                  if (context.mounted) Navigator.of(context).pop();
                  await setAsWallpaper();
                },
              ),
              RadioListTile<String>(
                title: Text(context.tr('wallpaperDetails.lockScreen')),
                value: WallpaperManagerPlus.lockScreen.toString(),
                groupValue: null,
                onChanged: (value) async {
                  setState(() {
                    wallLocation = WallpaperManagerPlus.lockScreen;
                  });
                  if (context.mounted) Navigator.of(context).pop();
                  await setAsWallpaper();
                },
              ),
              RadioListTile<String>(
                title: Text(context.tr('wallpaperDetails.both')),
                value: WallpaperManagerPlus.bothScreens.toString(),
                groupValue: null,
                onChanged: (value) async {
                  setState(() {
                    wallLocation = WallpaperManagerPlus.bothScreens;
                  });
                  if (context.mounted) Navigator.of(context).pop();
                  await setAsWallpaper();
                },
              ),
              RadioListTile<String>(
                title: Text(context.tr('wallpaperDetails.setWith')),
                value: '4',
                groupValue: null,
                onChanged: (value) async {
                  setState(() {
                    wallLocation = 4;
                  });
                  if (context.mounted) Navigator.of(context).pop();
                  await setAsWallpaper();
                },
              ),
            ])));
      },
    );
  }

  bool isFaved = false;

  checkIfFaved() async {
    var table = await sqlDb.selectData("SELECT * FROM 'wallfavs'");
    for (var row in table) {
      if (widget.wallpaperUrlHq == row['wallurlhq']) {
        setState(() {
          isFaved = true;
        });
        break;
      }
    }
  }

  insertOrDeleteFaved() async {
    if (isFaved) {
      await sqlDb.deleteData(
          "DELETE FROM 'wallfavs' WHERE wallurlhq = '${widget.wallpaperUrlHq}'");
      setState(() {
        isFaved = false;
      });
      showToast(
        context.tr('wallpaperDetails.removedFromFavorites'),
        duration: const Duration(milliseconds: 1500),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        // ignore: use_build_context_synchronously
        context: context,
      );
    } else {
      await sqlDb.insertData(
          "INSERT INTO 'wallfavs' ('wallurlhq', 'wallurlmid', 'wallurllow', 'wallname', 'wallresolution', 'wallsize', 'wallcategory', 'wallcolors' )VALUES ('${widget.wallpaperUrlHq}', '${widget.wallpaperUrlMid}', '${widget.wallpaperUrlLow}', '${widget.wallpaperName}', '${widget.wallpaperResolution}', '${widget.wallpaperSize}', '${widget.wallpaperCategory}', '${widget.wallpaperColors}' )");
      setState(() {
        isFaved = true;
      });
      showToast(
        context.tr('wallpaperDetails.addedToFavorites'),
        duration: const Duration(milliseconds: 1500),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        // ignore: use_build_context_synchronously
        context: context,
      );
      AnalyticsEngine.wallpaperFaved(widget.wallpaperName);
    }
  }

  Color? containerColor1 = const Color.fromARGB(255, 0, 0, 0);
  Color? containerColor2 = const Color.fromARGB(255, 0, 0, 0);
  Color? containerColor3 = const Color.fromARGB(255, 0, 0, 0);
  Color? containerColor4 = const Color.fromARGB(255, 0, 0, 0);

  String calculateSize() {
    double size = (widget.wallpaperSize / 1024 / 1024);
    return "${size.toStringAsFixed(2)} MB";
  }

  getColors() {
    String fixedColors = widget.wallpaperColors
        .replaceAll('[', '["')
        .replaceAll(']', '"]')
        .replaceAll(', ', '", "')
        .replaceAll('#', '#');
    List<String> listedColors =
        json.decode(fixedColors).cast<String>().toList();
    // Convert hex strings to Color objects
    List<Color> colors = listedColors.map((hex) {
      // Remove '#' and parse the hex code to a Color
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    }).toList();

    setState(() {
      containerColor1 = colors[0];
      containerColor2 = colors[1];
      containerColor3 = colors[2];
      containerColor4 = colors[3];
    });
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Wallpaper Details View");
    checkIfFaved();
    getColors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 50, 20, 15),
              height: MediaQuery.sizeOf(context).height / 1.8,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CustomPageRoute(
                      builder: (context) => WallpaperFullscreenView(
                        wallpaperUrlHq: widget.wallpaperUrlHq,
                        wallpaperUrlMid: widget.wallpaperUrlMid,
                        wallpaperUrlLow: widget.wallpaperUrlLow,
                      ),
                      duration: const Duration(milliseconds: 600),
                    ),
                  );
                },
                child: WallpaperCard(
                  wallpaperUrlHq: widget.wallpaperUrlHq,
                  wallpaperUrlMid: widget.wallpaperUrlMid,
                  wallpaperUrlLow: widget.wallpaperUrlLow,
                  isWallpaper: true,
                  lowQuality: false,
                ),
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 30),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 153,
                  child: Text(
                    widget.wallpaperName.replaceAll("_", " "),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.clip,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.verified_rounded,
                  size: 35,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 2),
                IconButton(
                  onPressed: insertOrDeleteFaved,
                  tooltip: 'Favorite',
                  iconSize: 35,
                  icon: Icon(
                    isFaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                SizedBox(
                  height: 50,
                  child: TextButton.icon(
                    onPressed: showSetWallpaperDialog,
                    label: Text(
                      context.tr('wallpaperDetails.setAsWallpaper'),
                      style: const TextStyle(fontSize: 23),
                    ),
                    icon: const Icon(
                      Icons.wallpaper_rounded,
                      size: 27,
                    ),
                  ),
                ),
              ],
            ),
            Card(
              margin: const EdgeInsets.all(20),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${context.tr('wallpaperDetails.resolution')}:  ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                    text: widget.wallpaperResolution,
                                    style: TextStyle(
                                      fontSize: 15,
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
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${context.tr('wallpaperDetails.size')}:  ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                    text: calculateSize(),
                                    style: TextStyle(
                                      fontSize: 15,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${context.tr('wallpaperDetails.category')}:  ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                    text: widget.wallpaperCategory,
                                    style: TextStyle(
                                      fontSize: 15,
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
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: saveNetworkImage,
                              label: Text(context.tr('wallpaperDetails.save'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                  )),
                              icon: const Icon(Icons.download_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.tr('wallpaperDetails.colorsUsed'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            containerColor1 == null
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: containerColor1!),
                            containerColor2 == null
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: containerColor2!),
                            containerColor3 == null
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: containerColor3!),
                            containerColor4 == null
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: containerColor4!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
