import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flexify/src/analytics_engine.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class DepthWallFullscreenView extends StatefulWidget {
  final String depthWallThumbnailUrl;

  const DepthWallFullscreenView({
    super.key,
    required this.depthWallThumbnailUrl,
  });

  @override
  State<DepthWallFullscreenView> createState() =>
      _DepthWallFullscreenViewState();
}

class _DepthWallFullscreenViewState extends State<DepthWallFullscreenView> {
  late TransformationController _controller;
  bool isAmbientEffectEnabled = true;

  @override
  void initState() {
    AnalyticsEngine.pageOpened("Depth Wall Fullscreen View");
    _controller = TransformationController();
    getAmbientEffectPref();
    super.initState();
  }

  getAmbientEffectPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? ambientEffectEnabled = prefs.getBool('isAmbientEffectEnabled');
    setState(() {
      isAmbientEffectEnabled = ambientEffectEnabled ?? true;
    });
  }

  @override
  void dispose() {
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
          if (isAmbientEffectEnabled) ...[
            Positioned.fill(
              child: Transform.scale(
                scale: 1.2,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: CachedNetworkImage(
                    imageUrl: widget.depthWallThumbnailUrl,
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
          ],
          // Main interactive wallpaper
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
              child: Hero(
                tag: widget.depthWallThumbnailUrl,
                child: InteractiveViewer(
                  transformationController: _controller,
                  minScale: 0.1,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.depthWallThumbnailUrl,
                    fit: BoxFit
                        .cover, // Use cover instead of contain for depth walls
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
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
