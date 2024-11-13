import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/widgets/color_container.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

class WallpaperDetailsView extends StatefulWidget {
  final String wallpaperUrl;
  final String wallpaperName;
  final String wallpaperAuthor;
  final UniqueKey uniqueKey;

  static const routeName = '/wallpapers_details';

  const WallpaperDetailsView({
    super.key,
    required this.wallpaperUrl,
    required this.wallpaperName,
    required this.wallpaperAuthor,
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
      var response = await Dio().get(widget.wallpaperUrl,
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
        .getSingleFile(widget.wallpaperUrl, key: widget.wallpaperUrl);
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
      if (widget.wallpaperUrl == row['wallurl']) {
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
          "DELETE FROM 'wallfavs' WHERE wallurl = '${widget.wallpaperUrl}'");
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
          "INSERT INTO 'wallfavs' ('wallurl', 'wallname', 'wallauthor')VALUES ('${widget.wallpaperUrl}', '${widget.wallpaperName}', '${widget.wallpaperAuthor}')");
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

  String imageDimensions = '';
  String imageSize = '';

  Color? dominantColor = const Color.fromARGB(255, 0, 0, 0);
  Color? lightVibrantColor = const Color.fromARGB(255, 0, 0, 0);
  Color? vibrantColor = const Color.fromARGB(255, 0, 0, 0);
  Color? darkVibrantColor = const Color.fromARGB(255, 0, 0, 0);
  Color? lightMutedColor = const Color.fromARGB(255, 0, 0, 0);
  Color? mutedColor = const Color.fromARGB(255, 0, 0, 0);
  Color? darkMutedColor = const Color.fromARGB(255, 0, 0, 0);

  getWallpaperInfo() async {
    final File image = await DefaultCacheManager().getSingleFile(
      widget.wallpaperUrl,
      key: widget.wallpaperUrl,
    );
    final decodedImage = await decodeImageFromList(image.readAsBytesSync());
    final double size = (image.readAsBytesSync().lengthInBytes / 1024 / 1024);

    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImage(decodedImage);

    setState(() {
      imageDimensions = "${decodedImage.width}×${decodedImage.height}";
      imageSize = "${size.toStringAsFixed(2)} MB";
      dominantColor = paletteGenerator.dominantColor?.color;
      lightVibrantColor = paletteGenerator.lightVibrantColor?.color;
      vibrantColor = paletteGenerator.vibrantColor?.color;
      darkVibrantColor = paletteGenerator.darkVibrantColor?.color;
      lightMutedColor = paletteGenerator.lightMutedColor?.color;
      mutedColor = paletteGenerator.mutedColor?.color;
      darkMutedColor = paletteGenerator.darkMutedColor?.color;
    });
  }

  @override
  void initState() {
    checkIfFaved();
    getWallpaperInfo();
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
                wallpaperUrl: widget.wallpaperUrl,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 60,
                  width: 250,
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
                              imageDimensions,
                              style: const TextStyle(fontSize: 15),
                            ).animate().fade(),
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
                              imageSize,
                              style: const TextStyle(fontSize: 15),
                            ).animate().fade(),
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
                            dominantColor == null ||
                                    dominantColor == Colors.black
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: dominantColor!),
                            lightVibrantColor == null ||
                                    lightVibrantColor == Colors.black
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: lightVibrantColor!),
                            vibrantColor == null || vibrantColor == Colors.black
                                ? const SizedBox()
                                : ColorContainer(containerColor: vibrantColor!),
                            darkVibrantColor == null ||
                                    darkVibrantColor == Colors.black
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: darkVibrantColor!),
                            lightMutedColor == null ||
                                    lightMutedColor == Colors.black
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: lightMutedColor!),
                            mutedColor == null || mutedColor == Colors.black
                                ? const SizedBox()
                                : ColorContainer(containerColor: mutedColor!),
                            darkMutedColor == null ||
                                    darkMutedColor == Colors.black
                                ? const SizedBox()
                                : ColorContainer(
                                    containerColor: darkMutedColor!),
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
