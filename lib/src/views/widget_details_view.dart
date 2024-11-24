import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flexify/src/database/database_helper.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:android_intent_plus/android_intent.dart';

class WidgetDetailsView extends StatefulWidget {
  final String widgetUrl;
  final String widgetThumbnailUrl;
  final String widgetName;
  final String widgetCategory;

  const WidgetDetailsView({
    super.key,
    required this.widgetUrl,
    required this.widgetThumbnailUrl,
    required this.widgetName,
    required this.widgetCategory,
  });

  @override
  State<WidgetDetailsView> createState() => _WidgetDetailsViewState();
}

class _WidgetDetailsViewState extends State<WidgetDetailsView> {
  DatabaseHelper sqlDb = DatabaseHelper();

  bool isFaved = false;

  checkIfFaved() async {
    var table = await sqlDb.selectData("SELECT * FROM 'widgetfavs'");
    for (var row in table) {
      if (widget.widgetUrl == row['widgeturl']) {
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
          "DELETE FROM 'widgetfavs' WHERE widgeturl = '${widget.widgetUrl}'");
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
          "INSERT INTO 'widgetfavs' ('widgeturl', 'widgetname', 'widgetcategory' )VALUES ('${widget.widgetUrl}', '${widget.widgetName}', '${widget.widgetCategory}' )");
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

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.fromLTRB(20, 15, 0, 10),
              child: const Text("Fetching Widget...")),
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

  Future<void> openKWGTFile(String fullPath) async {
    const packageName = 'org.kustom.widget';
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
      debugPrint('Opening .kwgt files is supported only on Android.');
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

  applyWidget() async {
    showLoaderDialog(context); // Show loading dialog
    // Make file path
    var tempDir = await getTemporaryDirectory();
    String fullPath = "${tempDir.path}/${widget.widgetName}.kwgt";

    // Download file
    Response response = await Dio().get(
      widget.widgetUrl,
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
    openKWGTFile(fullPath);
  }

  @override
  void initState() {
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
              height: 450,
              child: WallpaperCard(
                wallpaperUrlHq: widget.widgetThumbnailUrl,
                wallpaperUrlMid: widget.widgetThumbnailUrl,
                isWallpaper: false,
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 30),
                SizedBox(
                  width: 220,
                  child: Text(
                    widget.widgetName,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                SizedBox(
                  height: 60,
                  width: 240,
                  child: ElevatedButton.icon(
                    onPressed: applyWidget,
                    label: const Text(
                      "Apply Widget",
                      style: TextStyle(fontSize: 20),
                    ),
                    icon: const Icon(
                      Icons.widgets_rounded,
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
