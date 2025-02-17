import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flexify/src/analytics_engine.dart';

class WallpaperFullscreenView extends StatefulWidget {
  final String wallpaperUrlHq;
  final String wallpaperUrlMid;
  final String wallpaperUrlLow;

  const WallpaperFullscreenView({
    super.key,
    required this.wallpaperUrlHq,
    required this.wallpaperUrlMid,
    required this.wallpaperUrlLow,
  });

  @override
  State<WallpaperFullscreenView> createState() =>
      _WallpaperFullscreenViewState();
}

class _WallpaperFullscreenViewState extends State<WallpaperFullscreenView> {
  @override
  void initState() {
    AnalyticsEngine.pageOpened("Image Fullscreen View");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
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
          wallpaperUrlLow: widget.wallpaperUrlLow,
          isWallpaper: true,
          lowQuality: false,
        ),
      ),
    );
  }
}
