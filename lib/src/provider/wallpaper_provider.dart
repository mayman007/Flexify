import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flexify/src/utils/isolate_helpers.dart';
import 'package:flexify/src/utils/http_service.dart';

/// A provider class that manages fetching and storing wallpaper data.
class WallpaperProvider extends ChangeNotifier {
  final HttpService _httpService = HttpService();

  String _baseUrlHq = '';
  String _baseUrlMid = '';
  String _baseUrlLow = '';
  Map<String, String> _headers = {};
  List<String> _wallpaperNames = [];
  List<String> _wallpaperResolutions = [];
  List<int> _wallpaperSizes = [];
  List<String> _wallpaperCategories = [];
  List<dynamic> _wallpaperColors = [];
  List<String> _categoriesList = [];
  bool _isLoading = false;
  bool _isError = false;

  String get baseUrlHq => _baseUrlHq;
  String get baseUrlMid => _baseUrlMid;
  String get baseUrlLow => _baseUrlLow;
  Map<String, String> get headers => _headers;
  List<String> get wallpaperNames => _wallpaperNames;
  List<String> get wallpaperResolutions => _wallpaperResolutions;
  List<int> get wallpaperSizes => _wallpaperSizes;
  List<String> get wallpaperCategories => _wallpaperCategories;
  List<dynamic> get wallpaperColors => _wallpaperColors;
  List<String> get categoriesList => _categoriesList;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  /// Fetches the list of all wallpapers and their metadata from the remote API.
  ///
  /// It uses Firebase Remote Config to get API endpoints and headers.
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
      // Get API URLs and headers from HTTP service
      final apiUrls = await _httpService.getApiUrls();
      _baseUrlHq = apiUrls['walls_hq'] ?? '';
      _baseUrlMid = apiUrls['walls_mid'] ?? '';
      _baseUrlLow = apiUrls['walls_low'] ?? '';
      _headers = await _httpService.getHeaders();

      // Fetch JSON data using HTTP service
      final jsonString = await _httpService.fetchJsonData(_baseUrlHq);

      // Parse data in background isolate to avoid blocking UI
      final parseResult =
          await IsolateHelpers.parseWallpaperDataInIsolate(jsonString);

      _wallpaperNames = parseResult.wallpaperNames;
      _wallpaperResolutions = parseResult.wallpaperResolutions;
      _wallpaperSizes = parseResult.wallpaperSizes;
      _wallpaperCategories = parseResult.wallpaperCategories;
      _wallpaperColors = parseResult.wallpaperColors;
      _categoriesList = parseResult.categoriesList;
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

  /// Gets a preview image URL for a given category.
  ///
  /// It searches through the loaded wallpapers to find the first one
  /// belonging to the specified category.
  String? getCategoryPreviewImage(String categoryName) {
    try {
      log('Looking for category: $categoryName');
      log('Available categories: $_categoriesList');
      log('Total wallpapers: ${_wallpaperNames.length}');

      // Find the first wallpaper in this category from already loaded data
      for (int i = 0; i < _wallpaperCategories.length; i++) {
        if (_wallpaperCategories[i] == categoryName) {
          final wallpaperName = _wallpaperNames[i];
          final imageUrl = '$_baseUrlLow/$categoryName/$wallpaperName';
          log('Found preview image for $categoryName: $imageUrl');
          return imageUrl;
        }
      }
      log('No wallpaper found for category: $categoryName');
    } catch (e) {
      log('Error getting category preview: $e');
    }
    return null;
  }
}
