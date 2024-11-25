import 'dart:developer';

import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';

class WallpaperFullscreenView extends StatefulWidget {
  final String wallpaperUrlHq;
  final String wallpaperUrlMid;

  const WallpaperFullscreenView({
    super.key,
    required this.wallpaperUrlHq,
    required this.wallpaperUrlMid,
  });

  @override
  State<WallpaperFullscreenView> createState() =>
      _WallpaperFullscreenViewState();
}

class _WallpaperFullscreenViewState extends State<WallpaperFullscreenView> {
  final _noScreenshot = NoScreenshot.instance;

  disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    log('Screenshot Off: $result');
  }

  enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    log('Enable Screenshot: $result');
  }

  @override
  void initState() {
    disableScreenshot();
    super.initState();
  }

  @override
  void dispose() {
    enableScreenshot();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: WallpaperCard(
          wallpaperUrlHq: widget.wallpaperUrlHq,
          wallpaperUrlMid: widget.wallpaperUrlMid,
          isWallpaper: true,
        ),
      ),
    );
  }
}
