import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WallpaperProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = '${dotenv.env['API_URL']}/wallpapers';

  List<String> _wallpaperNames = [];
  bool _isLoading = false;
  bool _isError = false;

  List<String> get wallpaperNames => _wallpaperNames;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  Future<void> fetchWallpaperNames() async {
    _isLoading = true;
    _isError = false;
    notifyListeners();

    try {
      final response = await _dio.get(baseUrl);
      if (response.statusCode == 200 && response.data is List) {
        _wallpaperNames = List<String>.from(response.data);
      } else {
        _wallpaperNames = [];
      }
    } catch (e) {
      log('Error fetching wallpaper names: $e');
      _wallpaperNames = [];
      _isError = true;
    } finally {
      log("Wallpaper fetching done.");
      _isLoading = false;
    }
    notifyListeners();
  }
}
