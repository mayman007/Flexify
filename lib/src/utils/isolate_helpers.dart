import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flexify/src/utils/http_service.dart';

/// Helper class for running expensive operations in background isolates
class IsolateHelpers {
  /// Parse large JSON data in background isolate
  static Future<List<Map<String, dynamic>>> parseJsonInIsolate(
      String jsonString) async {
    return await compute(_parseJsonData, jsonString);
  }

  /// Process wallpaper data in background isolate
  static Future<WallpaperParseResult> parseWallpaperDataInIsolate(
      String jsonString) async {
    return await compute(_parseWallpaperData, jsonString);
  }

  /// Process widget data in background isolate
  static Future<WidgetParseResult> parseWidgetDataInIsolate(
      String jsonString) async {
    return await compute(_parseWidgetData, jsonString);
  }

  /// Process depth wall data in background isolate
  static Future<DepthWallParseResult> parseDepthWallDataInIsolate(
      String jsonString) async {
    return await compute(_parseDepthWallData, jsonString);
  }

  /// Download and process image data in background isolate
  static Future<Uint8List> downloadImageInIsolate(
      ImageDownloadParams params) async {
    return await compute(_downloadImage, params);
  }

  /// Generate color palette from image in background isolate
  static Future<List<String>> extractColorsInIsolate(
      Uint8List imageBytes) async {
    return await compute(_extractColors, imageBytes);
  }
}

/// Static functions for isolate execution

List<Map<String, dynamic>> _parseJsonData(String jsonString) {
  try {
    final decoded = json.decode(jsonString);
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    }
    return [];
  } catch (e) {
    debugPrint('Error parsing JSON in isolate: $e');
    return [];
  }
}

WallpaperParseResult _parseWallpaperData(String jsonString) {
  try {
    final decoded = json.decode(jsonString);
    if (decoded is! List) {
      return WallpaperParseResult.empty();
    }

    final List<String> wallpaperNames = [];
    final List<String> wallpaperResolutions = [];
    final List<int> wallpaperSizes = [];
    final List<String> wallpaperCategories = [];
    final List<dynamic> wallpaperColors = [];
    final List<String> categoriesList = [];

    for (Map wallpaper in decoded) {
      wallpaperNames.add(wallpaper["name"] ?? "");
      wallpaperResolutions.add(wallpaper["resolution"] ?? "");
      wallpaperSizes.add(wallpaper["size"] ?? 0);
      wallpaperCategories.add(wallpaper["category"] ?? "");
      wallpaperColors.add(wallpaper["colors"] ?? []);

      final category = wallpaper["category"] ?? "";
      if (category.isNotEmpty && !categoriesList.contains(category)) {
        categoriesList.add(category);
      }
    }

    return WallpaperParseResult(
      wallpaperNames: wallpaperNames,
      wallpaperResolutions: wallpaperResolutions,
      wallpaperSizes: wallpaperSizes,
      wallpaperCategories: wallpaperCategories,
      wallpaperColors: wallpaperColors,
      categoriesList: categoriesList,
    );
  } catch (e) {
    debugPrint('Error parsing wallpaper data in isolate: $e');
    return WallpaperParseResult.empty();
  }
}

WidgetParseResult _parseWidgetData(String jsonString) {
  try {
    final decoded = json.decode(jsonString);
    if (decoded is! List) {
      return WidgetParseResult.empty();
    }

    final List<String> widgetNames = [];
    final List<String> widgetCategories = [];
    final List<String> categoriesList = [];

    for (Map widget in decoded) {
      if (widget["type"] == "kwgt") {
        widgetNames.add(widget["name"] ?? "");
        widgetCategories.add(widget["category"] ?? "");

        final category = widget["category"] ?? "";
        if (category.isNotEmpty && !categoriesList.contains(category)) {
          categoriesList.add(category);
        }
      }
    }

    return WidgetParseResult(
      widgetNames: widgetNames,
      widgetCategories: widgetCategories,
      categoriesList: categoriesList,
    );
  } catch (e) {
    debugPrint('Error parsing widget data in isolate: $e');
    return WidgetParseResult.empty();
  }
}

DepthWallParseResult _parseDepthWallData(String jsonString) {
  try {
    final decoded = json.decode(jsonString);
    if (decoded is! List) {
      return DepthWallParseResult.empty();
    }

    final List<String> depthWallNames = [];

    for (Map depthWall in decoded) {
      if (depthWall["type"] == "klwp") {
        depthWallNames.add(depthWall["name"] ?? "");
      }
    }

    return DepthWallParseResult(depthWallNames: depthWallNames);
  } catch (e) {
    debugPrint('Error parsing depth wall data in isolate: $e');
    return DepthWallParseResult.empty();
  }
}

Future<Uint8List> _downloadImage(ImageDownloadParams params) async {
  try {
    return await HttpService.downloadImageInIsolate(params.url, params.headers);
  } catch (e) {
    debugPrint('Error downloading image in isolate: $e');
    rethrow;
  }
}

List<String> _extractColors(Uint8List imageBytes) {
  // Placeholder for color extraction logic
  // You could implement actual color analysis here
  return ['#FFFFFF', '#000000', '#FF0000', '#00FF00'];
}

/// Data classes for isolate communication

class WallpaperParseResult {
  final List<String> wallpaperNames;
  final List<String> wallpaperResolutions;
  final List<int> wallpaperSizes;
  final List<String> wallpaperCategories;
  final List<dynamic> wallpaperColors;
  final List<String> categoriesList;

  WallpaperParseResult({
    required this.wallpaperNames,
    required this.wallpaperResolutions,
    required this.wallpaperSizes,
    required this.wallpaperCategories,
    required this.wallpaperColors,
    required this.categoriesList,
  });

  factory WallpaperParseResult.empty() {
    return WallpaperParseResult(
      wallpaperNames: [],
      wallpaperResolutions: [],
      wallpaperSizes: [],
      wallpaperCategories: [],
      wallpaperColors: [],
      categoriesList: [],
    );
  }
}

class WidgetParseResult {
  final List<String> widgetNames;
  final List<String> widgetCategories;
  final List<String> categoriesList;

  WidgetParseResult({
    required this.widgetNames,
    required this.widgetCategories,
    required this.categoriesList,
  });

  factory WidgetParseResult.empty() {
    return WidgetParseResult(
      widgetNames: [],
      widgetCategories: [],
      categoriesList: [],
    );
  }
}

class DepthWallParseResult {
  final List<String> depthWallNames;

  DepthWallParseResult({required this.depthWallNames});

  factory DepthWallParseResult.empty() {
    return DepthWallParseResult(depthWallNames: []);
  }
}

class ImageDownloadParams {
  final String url;
  final Map<String, String> headers;

  ImageDownloadParams({
    required this.url,
    required this.headers,
  });
}
