import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'dart:ui';

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
  late TransformationController _controller;

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Image Fullscreen View");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = TransformationController();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient background effect
          Positioned.fill(
            child: Transform.scale(
              scale: 1.2,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: CachedNetworkImage(
                  imageUrl: widget.wallpaperUrlLow,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          // Overlay to reduce ambient effect intensity
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          // Main interactive wallpaper
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 0.1,
              maxScale: 4.0,
              child: Center(
                child: Hero(
                  tag: widget.wallpaperUrlHq,
                  child: CachedNetworkImage(
                    imageUrl: widget.wallpaperUrlHq,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    placeholder: (context, url) => CachedNetworkImage(
                      imageUrl: widget.wallpaperUrlMid,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      placeholder: (context, url) => CachedNetworkImage(
                        imageUrl: widget.wallpaperUrlLow,
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
