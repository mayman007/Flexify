import 'dart:developer' show log;
import 'dart:io';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/utils/favorites_notifier.dart';
import 'package:flexify/src/provider/depthwall_provider.dart';
import 'package:flexify/src/views/depthwall_fullscreen_view.dart';
import 'package:flexify/src/utils/custom_page_route.dart';
import 'package:flexify/src/utils/http_service.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A view that displays the details of a selected depth wallpaper.
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

/// State for [DepthWallDetailsView].
class _DepthWallDetailsViewState extends State<DepthWallDetailsView> {
  final HttpService _httpService = HttpService();
  DatabaseHelper sqlDb = DatabaseHelper();

  bool isFaved = false;
  bool isAmbientEffectEnabled = true;
  final FavoritesNotifier _favoritesNotifier = FavoritesNotifier();

  /// Checks if the depth wallpaper is already in the favorites database.
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

  /// Inserts or deletes the depth wall from the favorites database.
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

    // Notify that favorites have changed
    _favoritesNotifier.notifyFavoritesChanged();
  }

  /// Retrieves the user's preference for the ambient background effect.
  getAmbientEffectPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? ambientEffectEnabled = prefs.getBool('isAmbientEffectEnabled');
    setState(() {
      isAmbientEffectEnabled = ambientEffectEnabled ?? true;
    });
  }

  /// Shows a loading dialog.
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

  /// Shows a dialog indicating that KLWP is not installed.
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

  /// Opens the specified .klwp file using an Android Intent with the KLWP package.
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

  /// Downloads the depth wallpaper, saves it to a temporary file, and opens it with KLWP.
  applyDepthWall() async {
    // Check if KLWP is installed
    bool? appIsInstalled =
        await InstalledApps.isAppInstalled('org.kustom.wallpaper');
    if (appIsInstalled == null || appIsInstalled == false) {
      showAppNotFoundDialog(context);
      return;
    }
    showLoaderDialog(context); // Show loading dialog

    try {
      // Make file path
      var tempDir = await getTemporaryDirectory();
      String fullPath = "${tempDir.path}/${widget.depthWallName}.klwp";

      // Get headers from provider
      final depthWallProvider =
          Provider.of<DepthWallProvider>(context, listen: false);
      Map<String, String> headers = depthWallProvider.headers;

      // Download file using HTTP service
      final fileBytes = await _httpService.downloadFile(widget.depthWallUrl,
          customHeaders: headers);

      // Write file
      File file = File(fullPath);
      await file.writeAsBytes(fileBytes);

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
    } catch (e) {
      Navigator.pop(context);
      showToast(
        context.tr('depthWalls.downloadError'),
        animation: StyledToastAnimation.fade,
        reverseAnimation: StyledToastAnimation.fade,
        // ignore: use_build_context_synchronously
        context: context,
      );
      log('Error downloading depth wall: $e');
    }
  }

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Depth Wall Details View");
    checkIfFaved();
    getAmbientEffectPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
          tag: 'app-bar',
          child: Material(
            color: Colors.transparent,
            child: SizedBox.shrink(),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 50, 20, 15),
                  height: MediaQuery.sizeOf(context).height / 1.8,
                  child: Stack(
                    children: [
                      // Ambient background effect
                      if (isAmbientEffectEnabled) ...[
                        Positioned.fill(
                          child: Transform.scale(
                            scale: 1.2,
                            child: ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                      ], // Main wallpaper card
                      GestureDetector(
                        onTap: () {
                          // Hide system UI before starting navigation for smooth transition
                          SystemChrome.setEnabledSystemUIMode(
                              SystemUiMode.immersiveSticky);

                          Navigator.push(
                            context,
                            CustomPageRoute(
                              builder: (context) => DepthWallFullscreenView(
                                  depthWallThumbnailUrl:
                                      widget.depthWallThumbnailUrl),
                              duration: const Duration(milliseconds: 600),
                            ),
                          ).then((_) {
                            // Restore system UI when returning from fullscreen
                            SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.manual,
                                overlays: [
                                  SystemUiOverlay.top,
                                  SystemUiOverlay.bottom,
                                ]);
                          });
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Hero(
              tag: 'bottom-nav-bar',
              child: Material(
                color: Colors.transparent,
                child: SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
