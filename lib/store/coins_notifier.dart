import 'package:flutter/foundation.dart';

class CoinsChangeNotifier extends ChangeNotifier {
  static final CoinsChangeNotifier _instance = CoinsChangeNotifier._internal();
  factory CoinsChangeNotifier() => _instance;
  CoinsChangeNotifier._internal();

  void notifyCoinsChanged() {
    notifyListeners();
  }
}

final coinsChangeNotifier = CoinsChangeNotifier();
