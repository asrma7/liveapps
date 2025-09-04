import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/search_bar.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // Dummy app data
  final List<Map<String, dynamic>> apps = [
    {
      "name": "GoCoEdit_23.0",
      "version": "23.0",
      "description": "Fast iOS Remote & Local Code Editor",
      "downloadURL": "https://ipa.cypwn.xyz/ipas/GoCoEdit_23.0.ipa",
      "iconURL": "https://ipa.cypwn.xyz/serve/icons/GoCoEdit_23.0.png",
      "repoIconURL": "https://repo.cypwn.xyz/assets/images/cypwn_small.png",
    },
    {
      "name": "CleanMyPhone",
      "version": "2.9.0",
      "description": "Injected with Subscription Unlocked",
      "downloadURL":
          "https://github.com/apptesters-org/AppTesters_Repo/releases/download/04-09-2025/CleanMyPhone_2.9.0_Subscription_Unlocked_%40thisismanpreets_apptesters.org.ipa",
      "iconURL":
          "https://raw.githubusercontent.com/apptesters-org/AppTesters_Repo/main/icons/com.macpaw.iosgemini.png",
      "repoIconURL":
          "https://apptesters.org/wp-content/uploads/2024/04/AppTesters-Logo-Site-Icon.webp",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        leading: Text("Library"),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(8.0), child: AppSearchBar()),
            Expanded(
              child: CupertinoScrollbar(
                child: ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: CupertinoListTile(
                        leading: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                app["iconURL"],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  app["repoIconURL"],
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(app["name"]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Version: ${app["version"]}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            Text(
                              app["description"],
                              style: const TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // Handle download action
                          },
                          child: Icon(
                            Ionicons.download_outline,
                            size: 24,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
