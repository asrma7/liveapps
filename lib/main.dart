import 'package:flutter/cupertino.dart';
import 'package:liveapps/app.dart';

import 'package:liveapps/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(const MyApp());
}
