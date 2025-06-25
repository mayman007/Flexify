import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Centralized HTTP service for handling all network requests
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final Dio _dio = Dio();
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Initialize Remote Config settings
  Future<void> _initRemoteConfig() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  /// Get headers from Remote Config
  Future<Map<String, String>> _getHeaders() async {
    await _initRemoteConfig();
    String headersJson = _remoteConfig.getString('api_headers');
    return Map<String, String>.from(json.decode(headersJson));
  }

  /// Get API URLs from Remote Config
  Future<Map<String, String>> getApiUrls() async {
    await _initRemoteConfig();
    return {
      'widgets': _remoteConfig.getString('widgets'),
      'walls_hq': _remoteConfig.getString('walls_hq'),
      'walls_mid': _remoteConfig.getString('walls_mid'),
      'walls_low': _remoteConfig.getString('walls_low'),
      'depth_walls': _remoteConfig.getString('depth_walls'),
    };
  }

  /// Generic GET request for JSON data
  Future<String> fetchJsonData(String url,
      {Map<String, String>? customHeaders}) async {
    try {
      final headers = customHeaders ?? await _getHeaders();

      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data is String
            ? response.data
            : json.encode(response.data);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching data from $url: $e');
      rethrow;
    }
  }

  /// Download file as bytes (for widgets, depth walls, images)
  Future<Uint8List> downloadFile(String url,
      {Map<String, String>? customHeaders}) async {
    try {
      final headers = customHeaders ?? await _getHeaders();

      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      log('Error downloading file from $url: $e');
      rethrow;
    }
  }

  /// Download image with specific headers (for isolate use)
  static Future<Uint8List> downloadImageInIsolate(
      String url, Map<String, String> headers) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
        ),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      log('Error downloading image in isolate: $e');
      rethrow;
    }
  }

  /// Get headers for external use (providers, etc.)
  Future<Map<String, String>> getHeaders() async {
    return await _getHeaders();
  }
}
