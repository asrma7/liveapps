import 'package:flutter/cupertino.dart';
import 'package:liveapps/app.dart';
import 'package:provider/provider.dart';
import 'package:liveapps/notifiers/apps_notifier.dart';
import 'package:liveapps/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppsNotifier()..fetchApps(),
      child: const MyApp(),
    ),
  );
}
