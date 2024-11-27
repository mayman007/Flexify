import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WallpaperProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrlHq =
      '${utf8.decode(base64.decode(dotenv.env['ENCRYPTED']!))}/wallpapers/hq';
  final String baseUrlMid =
      '${utf8.decode(base64.decode(dotenv.env['ENCRYPTED']!))}/wallpapers/mid';
  final String baseUrlLow =
      '${utf8.decode(base64.decode(dotenv.env['ENCRYPTED']!))}/wallpapers/low';

  List<String> _wallpaperNames = [];
  List<String> _wallpaperResolutions = [];
  List<int> _wallpaperSizes = [];
  List<String> _wallpaperCategories = [];
  List<dynamic> _wallpaperColors = [];
  List<String> _categoriesList = [];
  bool _isLoading = false;
  bool _isError = false;

  List<String> get wallpaperNames => _wallpaperNames;
  List<String> get wallpaperResolutions => _wallpaperResolutions;
  List<int> get wallpaperSizes => _wallpaperSizes;
  List<String> get wallpaperCategories => _wallpaperCategories;
  List<dynamic> get wallpaperColors => _wallpaperColors;
  List<String> get categoriesList => _categoriesList;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  Future<void> fetchWallpaperData() async {
    _wallpaperNames = [];
    _wallpaperResolutions = [];
    _wallpaperSizes = [];
    _wallpaperCategories = [];
    _wallpaperColors = [];
    _isLoading = true;
    _isError = false;
    notifyListeners();

    try {
      final response = await _dio.get(baseUrlHq);
      if (response.statusCode == 200 && response.data is List) {
        for (Map wallpaper in response.data) {
          _wallpaperNames.add(wallpaper["name"]);
          _wallpaperResolutions.add(wallpaper["resolution"]);
          _wallpaperSizes.add(wallpaper["size"]);
          _wallpaperCategories.add(wallpaper["category"]);
          _wallpaperColors.add(wallpaper["colors"]);
          if (!_categoriesList.contains(wallpaper["category"])) {
            _categoriesList.add(wallpaper["category"]);
          }
        }
      } else {
        _wallpaperNames = [];
        _wallpaperResolutions = [];
        _wallpaperSizes = [];
        _wallpaperCategories = [];
        _wallpaperColors = [];
        _categoriesList = [];
      }
    } catch (e) {
      log('Error fetching wallpaper names: $e');
      _wallpaperNames = [];
      _wallpaperResolutions = [];
      _wallpaperSizes = [];
      _wallpaperCategories = [];
      _wallpaperColors = [];
      _categoriesList = [];
      _isError = true;
    } finally {
      log("Wallpaper fetching done.");
      _isLoading = false;
    }
    notifyListeners();
  }
}
