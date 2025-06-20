import 'dart:io';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/views/wallpaper_fullscreen_view.dart';
import 'package:flexify/src/widgets/custom_page_route.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class DepthWallDetailsView extends StatefulWidget {
  final String depthWallUrl;
  final String depthWallThumbnailUrl;
  final String depthWallName;

  const DepthWallDetailsView({
    super.key,
    required this.depthWallUrl,
    required this.depthWallThumbnailUrl,
    required this.depthWallName,
  });

  @override
  State<DepthWallDetailsView> createState() => _DepthWallDetailsViewState();
}

class _DepthWallDetailsViewState extends State<DepthWallDetailsView> {
  DatabaseHelper sqlDb = DatabaseHelper();

  bool isFaved = false;

  checkIfFaved() async {
    var table = await sqlDb.selectData("SELECT * FROM 'lockscreenfavs'");
    for (var row in table) {
      if (widget.depthWallUrl == row['lockscreenurl']) {
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
          "DELETE FROM 'lockscreenfavs' WHERE lockscreenurl = '${widget.depthWallUrl}'");
      setState(() {
        isFaved = false;
      });
      showToast(
        context.tr('favorites.removedFromFavorites'),
        duration: const Duration(milliseconds: 1500),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        // ignore: use_build_context_synchronously
        context: context,
      );
    } else {
      await sqlDb.insertData(
          "INSERT INTO 'lockscreenfavs' ('lockscreenurl', 'lockscreenname' )VALUES ('${widget.depthWallUrl}', '${widget.depthWallName}' )");
      setState(() {
        isFaved = true;
      });
      showToast(
        context.tr('favorites.addedToFavorites'),
        duration: const Duration(milliseconds: 1500),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        // ignore: use_build_context_synchronously
        context: context,
      );
      AnalyticsEngine.depthWallFaved(widget.depthWallName);
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.fromLTRB(20, 15, 0, 10),
              child: Text(context.tr('depthWalls.fetchingDepthWallpaper'))),
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

  showAppNotFoundDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            content: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      context.tr('depthWalls.needKLWP'),
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    )
                  ]),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse(
                      'https://play.google.com/store/apps/details?id=org.kustom.wallpaper'));
                },
                child: Text(context.tr('depthWalls.getKLWP')),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://t.me/Flexify_discussion'));
                },
                child: Text(context.tr('widgets.telegramSupport')),
              )
            ],
          );
        });
  }

  Future<void> openKLWPFile(String fullPath) async {
    const packageName = 'org.kustom.wallpaper';
    if (Platform.isAndroid) {
      try {
        // Convert file URI to content URI using FileProvider
        final contentUri = await _getContentUri(fullPath);
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: contentUri,
          package: packageName,
          flags: <int>[
            268435456, // FLAG_ACTIVITY_NEW_TASK
            1, // FLAG_GRANT_READ_URI_PERMISSION
          ],
        );
        await intent.launch();
      } catch (e) {
        debugPrint('Error launching intent: $e');
      }
    } else {
      debugPrint('Opening .klwp files is supported only on Android.');
    }
  }

  /// Converts a file:// URI to a content:// URI using FileProvider.
  Future<String> _getContentUri(String filePath) async {
    final file = File(filePath);
    const authority = 'com.maymanxineffable.flexify.fileprovider';

    // Verify the file exists
    if (!file.existsSync()) {
      throw Exception("File not found: $filePath");
    }
    return 'content://$authority/cache_files/${Uri.encodeComponent(file.uri.pathSegments.last)}';
  }

  applyDepthWall() async {
    // Check if KLWP is installed
    bool? appIsInstalled =
        await InstalledApps.isAppInstalled('org.kustom.wallpaper');
    if (appIsInstalled == null || appIsInstalled == false) {
      showAppNotFoundDialog(context);
      return;
    }
    showLoaderDialog(context); // Show loading dialog

    // Make file path
    var tempDir = await getTemporaryDirectory();
    String fullPath = "${tempDir.path}/${widget.depthWallName}.klwp";

    // Download file
    Response response = await Dio().get(
      widget.depthWallUrl,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
    );

    // Write file
    File file = File(fullPath);
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();

    // Open file
    Navigator.pop(context);
    openKLWPFile(fullPath);
    showToast(
      context.tr('depthWalls.openedKLWP'),
      animation: StyledToastAnimation.fade,
      reverseAnimation: StyledToastAnimation.fade,
      // ignore: use_build_context_synchronously
      context: context,
    );
    AnalyticsEngine.depthWallApplied(widget.depthWallName);
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Depth Wall Details View");
    checkIfFaved();
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
              child: Stack(
                children: [
                  // Ambient background effect
                  Positioned.fill(
                    child: Transform.scale(
                      scale: 1.2,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CachedNetworkImage(
                                imageUrl: widget.depthWallThumbnailUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Overlay to reduce ambient effect intensity
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues()
                            .withAlpha(0),
                      ),
                    ),
                  ),
                  // Main wallpaper card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomPageRoute(
                          builder: (context) => WallpaperFullscreenView(
                            wallpaperUrlHq: widget.depthWallThumbnailUrl,
                            wallpaperUrlMid: widget.depthWallThumbnailUrl,
                            wallpaperUrlLow: widget.depthWallThumbnailUrl,
                          ),
                          duration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    child: WallpaperCard(
                      wallpaperUrlHq: widget.depthWallThumbnailUrl,
                      wallpaperUrlMid: widget.depthWallThumbnailUrl,
                      wallpaperUrlLow: widget.depthWallThumbnailUrl,
                      isWallpaper: true,
                      lowQuality: true,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 30),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 153,
                  child: Text(
                    widget.depthWallName.replaceAll("_", " "),
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
                  tooltip: context.tr('favorites.favorite'),
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
                  height: 60,
                  child: TextButton.icon(
                    onPressed: applyDepthWall,
                    label: Text(
                      context.tr('depthWalls.applyDepthWallpaper'),
                      style: TextStyle(fontSize: 23),
                    ),
                    icon: const Icon(
                      Icons.photo_library_rounded,
                      size: 27,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
