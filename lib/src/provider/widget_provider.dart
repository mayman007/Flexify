import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flexify/src/utils/isolate_helpers.dart';
import 'package:flexify/src/utils/http_service.dart';

class WidgetProvider extends ChangeNotifier {
  final HttpService _httpService = HttpService();

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
    _widgetNames = [];
    _widgetCategories = [];
    _categoriesList = [];
    _isLoading = true;
    _isError = false;
    notifyListeners();

    try {
      // Get API URLs and headers from HTTP service
      final apiUrls = await _httpService.getApiUrls();
      _baseUrl = apiUrls['widgets'] ?? '';
      _headers = await _httpService.getHeaders();

      // Fetch JSON data using HTTP service
      final jsonString = await _httpService.fetchJsonData(_baseUrl);

      // Parse data in background isolate to avoid blocking UI
      final parseResult =
          await IsolateHelpers.parseWidgetDataInIsolate(jsonString);

      _widgetNames = parseResult.widgetNames;
      _widgetCategories = parseResult.widgetCategories;
      _categoriesList = parseResult.categoriesList;
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
