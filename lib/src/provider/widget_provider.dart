import 'dart:convert';
import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class WidgetProvider extends ChangeNotifier {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final Dio _dio = Dio();

  String _baseUrl = '';
  Map<String, String> _headers = {};
  List<String> _widgetNames = [];
  List<String> _widgetCategories = [];
  List<String> _categoriesList = [];
  bool _isLoading = false;
  bool _isError = false;

  String get baseUrl => _baseUrl;
  Map<String, String> get headers => _headers;
  List<String> get widgetNames => _widgetNames;
  List<String> get widgetCategories => _widgetCategories;
  List<String> get categoriesList => _categoriesList;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  Future<void> fetchWidgetData() async {
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
    _baseUrl = _remoteConfig.getString('widgets');

    _widgetNames = [];
    _widgetCategories = [];
    _categoriesList = [];
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
        for (Map widget in response.data) {
          if (widget["type"] == "kwgt") {
            _widgetNames.add(widget["name"]);
            _widgetCategories.add(widget["category"]);
            if (!_categoriesList.contains(widget["category"])) {
              _categoriesList.add(widget["category"]);
            }
          }
        }
      } else {
        _widgetNames = [];
        _widgetCategories = [];
        _categoriesList = [];
      }
    } catch (e) {
      log('Error fetching widget names: $e');

      _isError = true;
    } finally {
      log("Widget fetching done.");
      _isLoading = false;
    }
    notifyListeners();
  }
}
