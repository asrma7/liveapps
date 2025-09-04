import 'package:flutter/cupertino.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
        ),
        border: null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text("Settings content here")),
      ),
    );
  }
}
