import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'screens/sources_page.dart';
import 'screens/library_page.dart';
import 'screens/settings_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: MainTabScaffold(),
    );
  }
}

class MainTabScaffold extends StatelessWidget {
  const MainTabScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        height: 60,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.planet_outline),
            label: "Sources",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.book_outline),
            label: "Library",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.settings_outline),
            label: "Settings",
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const SourcesPage();
          case 1:
            return const LibraryPage();
          case 2:
            return const SettingsPage();
          default:
            return const LibraryPage();
        }
      },
    );
  }
}
