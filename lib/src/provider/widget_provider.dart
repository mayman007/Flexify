import 'dart:convert';
import 'dart:developer';
import 'package:flexify/src/env/env.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class WidgetProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = '${utf8.decode(base64.decode(Env.apiKey))}/widgets';

  List<String> _widgetNames = [];
  List<String> _widgetCategories = [];
  List<String> _categoriesList = [];
  bool _isLoading = false;
  bool _isError = false;

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
      final response = await _dio.get(baseUrl);
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
