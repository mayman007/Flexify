import 'dart:convert';
import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

/// A provider class that manages fetching and storing depth wallpaper data.
class DepthWallProvider extends ChangeNotifier {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final Dio _dio = Dio();

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
    _baseUrl = _remoteConfig.getString('depth_walls');

    _depthWallNames = [];
    _isLoading = true;
    _isError = false;
    notifyListeners();

    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(
          headers: _headers,
        ),
      );
      if (response.statusCode == 200 && response.data is List) {
        for (Map depthWall in response.data) {
          if (depthWall["type"] == "klwp") {
            _depthWallNames.add(depthWall["name"]);
          }
        }
      } else {
        _depthWallNames = [];
      }
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
