import 'package:flutter/foundation.dart';

class FavoritesNotifier extends ChangeNotifier {
  static final FavoritesNotifier _instance = FavoritesNotifier._internal();
  factory FavoritesNotifier() => _instance;
  FavoritesNotifier._internal();

  void notifyFavoritesChanged() {
    notifyListeners();
  }
}
