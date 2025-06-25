import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flexify/src/utils/isolate_helpers.dart';
import 'package:flexify/src/utils/http_service.dart';

/// A provider class that manages fetching and storing depth wallpaper data.
class DepthWallProvider extends ChangeNotifier {
  final HttpService _httpService = HttpService();

  String _baseUrl = '';
  Map<String, String> _headers = {};
  List<String> _depthWallNames = [];
  bool _isLoading = false;
  bool _isError = false;

  String get baseUrl => _baseUrl;
  Map<String, String> get headers => _headers;
  List<String> get depthWallNames => _depthWallNames;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  /// Fetches the list of depth wallpapers from the remote API.
  ///
  /// It uses Firebase Remote Config to get API endpoints and headers.
  Future<void> fetchDepthWallData() async {
    _depthWallNames = [];
    _isLoading = true;
    _isError = false;
    notifyListeners();

    try {
      // Get API URLs and headers from HTTP service
      final apiUrls = await _httpService.getApiUrls();
      _baseUrl = apiUrls['depth_walls'] ?? '';
      _headers = await _httpService.getHeaders();

      // Fetch JSON data using HTTP service
      final jsonString = await _httpService.fetchJsonData(_baseUrl);

      // Parse data in background isolate to avoid blocking UI
      final parseResult =
          await IsolateHelpers.parseDepthWallDataInIsolate(jsonString);

      _depthWallNames = parseResult.depthWallNames;
    } catch (e) {
      log('Error fetching depthWall names: $e');
      _depthWallNames = [];
      _isError = true;
    } finally {
      log("DepthWall fetching done.");
      _isLoading = false;
    }
    notifyListeners();
  }
}
