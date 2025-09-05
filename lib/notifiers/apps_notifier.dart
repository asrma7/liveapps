import 'package:flutter/foundation.dart';
import 'package:liveapps/models/app.dart';
import 'package:liveapps/database_helper.dart';

class AppsNotifier extends ChangeNotifier {
  List<App> _apps = [];
  bool _isLoading = false;

  List<App> get apps => _apps;
  bool get isLoading => _isLoading;

  Future<void> fetchApps() async {
    _isLoading = true;
    notifyListeners();
    final dbApps = await DatabaseHelper().getApps();
    _apps = dbApps.map((e) => App.fromMap(e)).toList();
    _isLoading = false;
    notifyListeners();
  }

  // Call this after a source is added
  Future<void> refreshApps() async {
    await fetchApps();
  }
}
