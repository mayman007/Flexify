import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

class WallpaperCard extends StatefulWidget {
  final String wallpaperUrlHq;
  final String wallpaperUrlMid;
  final String wallpaperUrlLow;
  final bool isWallpaper;
  final bool lowQuality;

  const WallpaperCard({
    super.key,
    required this.wallpaperUrlHq,
    required this.wallpaperUrlMid,
    required this.wallpaperUrlLow,
    required this.isWallpaper,
    required this.lowQuality,
  });

  @override
  WallpaperCardState createState() => WallpaperCardState();
}

class WallpaperCardState extends State<WallpaperCard>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // This is important to retain the state

    return Hero(
      tag: widget.wallpaperUrlHq,
      key: Key(widget.wallpaperUrlHq),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: widget.lowQuality
              ? widget.wallpaperUrlLow
              : widget.wallpaperUrlMid,
          key: widget.lowQuality
              ? Key(widget.wallpaperUrlLow)
              : Key(widget.wallpaperUrlMid),
          cacheManager: DefaultCacheManager(),
          placeholder: (context, url) => widget.lowQuality
              ? Center(
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surface,
                    highlightColor: Colors.grey,
                    child: Container(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: widget.wallpaperUrlLow,
                  key: Key(widget.wallpaperUrlLow),
                  cacheManager: DefaultCacheManager(),
                  placeholder: (context, url) => Center(
                    child: Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.surface,
                      highlightColor: Colors.grey,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: widget.isWallpaper ? BoxFit.cover : BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: widget.isWallpaper ? BoxFit.cover : BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
