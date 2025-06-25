import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flexify/src/utils/isolate_helpers.dart';
import 'package:flexify/src/utils/http_service.dart';

/// A provider class that manages fetching and storing wallpaper data for a specific category.
class WallpaperCategoryProvider extends ChangeNotifier {
  final HttpService _httpService = HttpService();

  Map<String, String> _headers = {};
  List<String> _wallpaperNames = [];
  List<String> _wallpaperResolutions = [];
  List<int> _wallpaperSizes = [];
  List<String> _wallpaperCategories = [];
  List<dynamic> _wallpaperColors = [];
  bool _isLoading = false;
  bool _isError = false;

  Map<String, String> get headers => _headers;
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
      // Get headers from HTTP service
      _headers = await _httpService.getHeaders();

      // Fetch JSON data using HTTP service
      final jsonString = await _httpService.fetchJsonData(url);

      // Parse data in background isolate to avoid blocking UI
      final parseResult =
          await IsolateHelpers.parseWallpaperDataInIsolate(jsonString);

      _wallpaperNames = parseResult.wallpaperNames;
      _wallpaperResolutions = parseResult.wallpaperResolutions;
      _wallpaperSizes = parseResult.wallpaperSizes;
      _wallpaperCategories = parseResult.wallpaperCategories;
      _wallpaperColors = parseResult.wallpaperColors;
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
