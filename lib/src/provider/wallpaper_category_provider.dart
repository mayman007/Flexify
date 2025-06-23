import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// A provider class that manages fetching and storing wallpaper data for a specific category.
class WallpaperCategoryProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  List<String> _wallpaperNames = [];
  List<String> _wallpaperResolutions = [];
  List<int> _wallpaperSizes = [];
  List<String> _wallpaperCategories = [];
  List<dynamic> _wallpaperColors = [];
  bool _isLoading = false;
  bool _isError = false;

  List<String> get wallpaperNames => _wallpaperNames;
  List<String> get wallpaperResolutions => _wallpaperResolutions;
  List<int> get wallpaperSizes => _wallpaperSizes;
  List<String> get wallpaperCategories => _wallpaperCategories;
  List<dynamic> get wallpaperColors => _wallpaperColors;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  /// Fetches the list of wallpapers and their metadata for a specific category URL.
  Future<void> fetchWallpaperCategoryData(String url) async {
    _wallpaperNames = [];
    _wallpaperResolutions = [];
    _wallpaperSizes = [];
    _wallpaperCategories = [];
    _wallpaperColors = [];
    _isLoading = true;
    _isError = false;
    notifyListeners();

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data is List) {
        for (Map wallpaper in response.data) {
          _wallpaperNames.add(wallpaper["name"]);
          _wallpaperResolutions.add(wallpaper["resolution"]);
          _wallpaperSizes.add(wallpaper["size"]);
          _wallpaperCategories.add(wallpaper["category"]);
          _wallpaperColors.add(wallpaper["colors"]);
        }
      } else {
        _wallpaperNames = [];
        _wallpaperResolutions = [];
        _wallpaperSizes = [];
        _wallpaperCategories = [];
        _wallpaperColors = [];
      }
    } catch (e) {
      log('Error fetching wallpaper names: $e');
      _wallpaperNames = [];
      _wallpaperResolutions = [];
      _wallpaperSizes = [];
      _wallpaperCategories = [];
      _wallpaperColors = [];
      _isError = true;
    } finally {
      log("Wallpaper fetching done.");
      _isLoading = false;
    }
    notifyListeners();
  }
}
