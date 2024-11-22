import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WidgetProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = '${dotenv.env['API_URL']}/widgets';

  List<String> _widgetNames = [];
  List<String> _widgetCategories = [];
  bool _isLoading = false;
  bool _isError = false;

  List<String> get widgetNames => _widgetNames;
  List<String> get widgetCategories => _widgetCategories;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  Future<void> fetchWidgetData() async {
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
          }
        }
      } else {
        _widgetNames = [];
        _widgetCategories = [];
      }
    } catch (e) {
      log('Error fetching widget names: $e');
      _widgetNames = [];
      _widgetCategories = [];
      _isError = true;
    } finally {
      log("Widget fetching done.");
      _isLoading = false;
    }
    notifyListeners();
  }
}
