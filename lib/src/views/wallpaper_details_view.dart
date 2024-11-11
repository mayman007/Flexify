import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flexify/src/widgets/wallpaper_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class WallpaperDetailsView extends StatefulWidget {
  final String wallpaperUrl;
  final String wallpaperName;
  final String wallpaperAuthor;
  final UniqueKey uniqueKey;

  static const routeName = '/wallpapers_details';

  const WallpaperDetailsView({
    super.key,
    required this.wallpaperUrl,
    required this.wallpaperName,
    required this.wallpaperAuthor,
    required this.uniqueKey,
  });

  @override
  State<WallpaperDetailsView> createState() => _WallpaperDetailsViewState();
}

class _WallpaperDetailsViewState extends State<WallpaperDetailsView> {
  saveNetworkImage() async {
    var response = await Dio().get(widget.wallpaperUrl,
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaverPlus.saveImage(
      Uint8List.fromList(response.data),
      // quality: 60,
      name: widget.wallpaperName,
    );
    Fluttertoast.showToast(
      msg: "Downloaded",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      // backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    log(result.toString());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      fit: StackFit.expand,
      borderRadius: BorderRadius.circular(15),
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
      showIcon: false,
      barColor: Theme.of(context).colorScheme.onPrimary,
      start: 2,
      end: 0,
      offset: 10,
      barAlignment: Alignment.bottomCenter,
      barDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      hideOnScroll: false,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: saveNetworkImage,
              icon: const Icon(Icons.download_rounded),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline_rounded),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_outline_rounded),
            ),
          ],
        ),
      ),
      body: (context, controller) => Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 50, 20, 15),
                height: 450,
                child: WallpaperCard(
                  wallpaperUrl: widget.wallpaperUrl,
                  uniqueKey: widget.uniqueKey,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30),
                  Text(
                    widget.wallpaperName,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30),
                  Text(
                    "@${widget.wallpaperAuthor}",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, size: 16)
                ],
              ),
              Card(
                margin: const EdgeInsets.all(20),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: const SizedBox(
                  height: 251,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: Text('This is the info card'),
                      ),
                      SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
