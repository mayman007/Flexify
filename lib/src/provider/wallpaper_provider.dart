import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WallpaperProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = '${dotenv.env['API_URL']}/wallpapers';

  List<String> _wallpaperNames = [];
  bool _isLoading = false;

  List<String> get wallpaperNames => _wallpaperNames;
  bool get isLoading => _isLoading;

  Future<void> fetchWallpaperNames() async {
    _isLoading = true;
    notifyListeners();

    try {
      log("1111");
      final response = await _dio.get(baseUrl);
      log("2222");
      log("RESPONSE IS: ${response.toString()}");
      if (response.statusCode == 200 && response.data is List) {
        _wallpaperNames = List<String>.from(response.data);
      } else {
        _wallpaperNames = [];
      }
    } catch (e) {
      log('Error fetching wallpaper names: $e');
      _wallpaperNames = [];
    } finally {
      log("wallpaperNAMES IS: $_wallpaperNames");
      _isLoading = false;
      notifyListeners();
    }
  }
}
