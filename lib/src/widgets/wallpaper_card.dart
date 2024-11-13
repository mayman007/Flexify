import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

class WallpaperCard extends StatefulWidget {
  final String wallpaperUrl;
  final UniqueKey uniqueKey;

  const WallpaperCard({
    super.key,
    required this.wallpaperUrl,
    required this.uniqueKey,
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
      tag: widget.wallpaperUrl,
      key: widget.uniqueKey,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: widget.wallpaperUrl,
          key: Key(widget.wallpaperUrl),
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
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
