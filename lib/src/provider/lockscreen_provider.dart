import 'dart:convert';
import 'dart:developer';
import 'package:flexify/src/env/env.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class LockscreenProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String baseUrl = '${utf8.decode(base64.decode(Env.apiKey))}/klwp';

  List<String> _lockscreenNames = [];
  bool _isLoading = false;
  bool _isError = false;

  List<String> get lockscreenNames => _lockscreenNames;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  Future<void> fetchLockscreenData() async {
    _lockscreenNames = [];
    _isLoading = true;
    _isError = false;
    notifyListeners();

    try {
      final response = await _dio.get(baseUrl);
      if (response.statusCode == 200 && response.data is List) {
        for (Map lockscreen in response.data) {
          if (lockscreen["type"] == "klwp") {
            _lockscreenNames.add(lockscreen["name"]);
          }
        }
      } else {
        _lockscreenNames = [];
      }
    } catch (e) {
      log('Error fetching lockscreen names: $e');

      _isError = true;
    } finally {
      log("Lockscreen fetching done.");
      _isLoading = false;
    }
    notifyListeners();
  }
}
