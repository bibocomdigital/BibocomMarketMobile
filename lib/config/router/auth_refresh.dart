import 'package:flutter/foundation.dart';

class AuthRefreshListenable extends ChangeNotifier {
  void ping() => notifyListeners();
}
