import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
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
        .getSingleFile(widget.wallpaperUrl, key: widget.uniqueKey.toString());
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
              'Set Wallpaper',
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
    } else {
      await sqlDb.insertData(
          "INSERT INTO 'wallfavs' ('wallurl', 'wallname', 'wallauthor')VALUES ('${widget.wallpaperUrl}', '${widget.wallpaperName}', '${widget.wallpaperAuthor}')");
      setState(() {
        isFaved = true;
      });
    }
  }

  @override
  void initState() {
    checkIfFaved();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      fit: StackFit.expand,
      borderRadius: BorderRadius.circular(15),
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
      showIcon: false,
      barColor: Theme.of(context).colorScheme.onPrimary,
      start: 2,
      end: 0,
      offset: 10,
      barAlignment: Alignment.bottomCenter,
      barDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      hideOnScroll: false,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: saveNetworkImage,
              icon: const Icon(Icons.download_rounded),
            ),
            IconButton(
              onPressed: showSetWallpaperDialog,
              icon: const Icon(Icons.check_circle_outline_rounded),
            ),
            IconButton(
              onPressed: insertOrDeleteFaved,
              icon: Icon(
                isFaved
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
              ),
            ),
          ],
        ),
      ),
      body: (context, controller) => Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30),
                  Text(
                    widget.wallpaperName,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30),
                  Text(
                    "@${widget.wallpaperAuthor}",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, size: 16)
                ],
              ),
              Card(
                margin: const EdgeInsets.all(20),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: const SizedBox(
                  height: 251,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: Text('This is the info card'),
                      ),
                      SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
