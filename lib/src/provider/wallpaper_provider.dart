import 'dart:convert';
import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// A provider class that manages fetching and storing wallpaper data.
class WallpaperProvider extends ChangeNotifier {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final Dio _dio = Dio();

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
    // Remote Config
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();

    // Use Remote Config values
    String headersJson = _remoteConfig.getString('api_headers');
    _headers = Map<String, String>.from(json.decode(headersJson));
    _baseUrlHq = _remoteConfig.getString('walls_hq');
    _baseUrlMid = _remoteConfig.getString('walls_mid');
    _baseUrlLow = _remoteConfig.getString('walls_low');

    _wallpaperNames = [];
    _wallpaperResolutions = [];
    _wallpaperSizes = [];
    _wallpaperCategories = [];
    _wallpaperColors = [];
    _isLoading = true;
    _isError = false;
    notifyListeners();

    try {
      final response = await _dio.get(
        _baseUrlHq,
        options: Options(
          headers: _headers,
        ),
      );
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
