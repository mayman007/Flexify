import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/widgets/color_container.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

class WallpaperDetailsView extends StatefulWidget {
  final String wallpaperUrlHq;
  final String wallpaperUrlMid;
  final String wallpaperName;
  final UniqueKey uniqueKey;
  final String wallpaperResolution;
  final int wallpaperSize;
  final String wallpaperCategory;
  final String wallpaperColors;

  static const routeName = '/wallpapers_details';

  const WallpaperDetailsView({
    super.key,
    required this.wallpaperUrlHq,
    required this.wallpaperUrlMid,
    required this.wallpaperName,
    required this.wallpaperResolution,
    required this.wallpaperSize,
    required this.wallpaperCategory,
    required this.wallpaperColors,
    required this.uniqueKey,
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
        "You has just downloaded this wallpaper! wait a few seconds.",
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        animDuration: const Duration(milliseconds: 500),
        // ignore: use_build_context_synchronously
        context: context,
      );
    } else {
      setState(() {
        saveImageCoolDown = true;
      });
      var response = await Dio().get(widget.wallpaperUrlHq,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        name: widget.wallpaperName,
      );
      showToast(
        "Wallpaper Downloaded",
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
    }
  }

  Future<void> setAsWallpaper() async {
    final file = await DefaultCacheManager()
        .getSingleFile(widget.wallpaperUrlHq, key: widget.wallpaperUrlHq);
    try {
      await WallpaperManagerPlus().setWallpaper(file, wallLocation);
    } catch (e) {
      log("Error setting wallpaper: $e");
    }
    setState(() {
      wallLocation = 0;
    });
    log("wallLocation $wallLocation");
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
            const Text(
              'Set as Wallpaper',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            RadioListTile<String>(
              title: const Text('Home Screen'),
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
              title: const Text('Lock Screen'),
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
              title: const Text('Both'),
              value: WallpaperManagerPlus.bothScreens.toString(),
              groupValue: null,
              onChanged: (value) async {
                setState(() {
                  wallLocation = WallpaperManagerPlus.bothScreens;
                });
                if (context.mounted) Navigator.of(context).pop();
                await setAsWallpaper();
              },
            )
          ],
        )));
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
        "Removed from Favorites",
        duration: const Duration(milliseconds: 1500),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        // ignore: use_build_context_synchronously
        context: context,
      );
    } else {
      await sqlDb.insertData(
          "INSERT INTO 'wallfavs' ('wallurlhq', 'wallurlmid', 'wallname', 'wallresolution', 'wallsize', 'wallcategory', 'wallcolors' )VALUES ('${widget.wallpaperUrlHq}', '${widget.wallpaperUrlMid}', '${widget.wallpaperName}', '${widget.wallpaperResolution}', '${widget.wallpaperSize}', '${widget.wallpaperCategory}', '${widget.wallpaperColors}' )");
      setState(() {
        isFaved = true;
      });
      showToast(
        "Added to Favorites",
        duration: const Duration(milliseconds: 1500),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        // ignore: use_build_context_synchronously
        context: context,
      );
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
    log(listedColors.toString());
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
              height: 450,
              child: WallpaperCard(
                wallpaperUrlHq: widget.wallpaperUrlHq,
                wallpaperUrlMid: widget.wallpaperUrlMid,
                uniqueKey: widget.uniqueKey,
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 30),
                SizedBox(
                  width: 220,
                  child: Text(
                    widget.wallpaperName,
                    style: const TextStyle(
                      fontSize: 23,
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 20),
                SizedBox(
                  height: 50,
                  width: 240,
                  child: ElevatedButton.icon(
                    onPressed: showSetWallpaperDialog,
                    label: const Text(
                      "Set as Wallpaper",
                      style: TextStyle(fontSize: 20),
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
                            const Text(
                              'Dimensions:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.wallpaperResolution,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            const Text(
                              'Size:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              calculateSize(),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Category:  ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.wallpaperCategory,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Colors Used',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
