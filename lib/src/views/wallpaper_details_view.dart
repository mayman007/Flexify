import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';

class WallpaperDetailsView extends StatefulWidget {
  final String wallpaperUrl;
  final String wallpaperName;
  final String wallpaperAuthor;
  final UniqueKey uniqueKey;

  static const routeName = '/wallpapers_details';

  const WallpaperDetailsView(
      {super.key,
      required this.wallpaperUrl,
      required this.wallpaperName,
      required this.wallpaperAuthor,
      required this.uniqueKey});

  @override
  State<WallpaperDetailsView> createState() => _WallpaperDetailsViewState();
}

class _WallpaperDetailsViewState extends State<WallpaperDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 50, 20, 15),
              height: 450,
              // width: 350,
              child: WallpaperCard(
                wallpaperUrl: widget.wallpaperUrl,
                uniqueKey: widget.uniqueKey,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 30),
                Text(
                  widget.wallpaperName,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 30),
                Text(
                  "@${widget.wallpaperAuthor}",
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.verified_rounded, size: 20)
              ],
            ),
            const SizedBox(height: 10),
            Card(
              margin: const EdgeInsets.all(20),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 251,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text('This is the info card'),
                    ),
                    const SizedBox(height: 95),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          label: const Text("Download"),
                          icon: const Icon(Icons.download_rounded),
                          onPressed: () {},
                        ),
                        ElevatedButton.icon(
                          label: const Text("Favourite"),
                          icon: const Icon(Icons.favorite_outline_rounded),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      label: const Text(
                        "Set as Wallpaper",
                        style: TextStyle(fontSize: 25),
                      ),
                      icon: const Icon(Icons.file_download_outlined, size: 35),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
