import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const platform = MethodChannel("example.startAccessingToSharedStorage");
  bool isLoading = true;
  late String liveContainerAppPath;

  @override
  void initState() {
    super.initState();
    _getLiveContainerAppPath();
  }

  Future<void> _getLiveContainerAppPath() async {
    try {
      final String result = await platform.invokeMethod("getWritableFilePath", {
        "fileName": "live.txt"
      });
      setState(() {
        liveContainerAppPath = result;
        isLoading = false;
      });
    } on PlatformException catch (e) {
      log("Error: '${e.message}'.");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('Settings')),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          color: CupertinoColors.systemBackground.resolveFrom(
                            context,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Ionicons.heart_outline,
                                  size: 50,
                                  color: Colors.red,
                                ),
                                const Text(
                                  'Made with ❤️ by Ashutosh',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Version 1.0.0',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'This app is open source. Check it out on GitHub!',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CupertinoColors
                                        .systemBackground
                                        .resolveFrom(context),
                                    foregroundColor: CupertinoColors.systemGrey,
                                  ),
                                  onPressed: () {
                                    url_launcher.launchUrl(
                                      Uri.parse(
                                        'https://github.com/asrma7/liveapps',
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Ionicons.logo_github),
                                      SizedBox(width: 8),
                                      Text('View on GitHub'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          color: CupertinoColors.systemBackground.resolveFrom(
                            context,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Text(
                                  "Live Container App Path:",
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final folder = await FilePicker.platform
                                          .getDirectoryPath();
                                      if (folder != null) {
                                        await platform.invokeMethod(
                                          "saveSharedFolder", {"url": folder}
                                        );
                                        setState(() {
                                          liveContainerAppPath = folder;
                                        });
                                      } else {
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (context) {
                                            return CupertinoAlertDialog(
                                              title: const Text("Error"),
                                              content: const Text(
                                                "Failed to pick folder",
                                              ),
                                              actions: [
                                                CupertinoDialogAction(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Tooltip(
                                      message: liveContainerAppPath,
                                      child: Text(
                                        liveContainerAppPath,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color:
                                              liveContainerAppPath == 'Not Set'
                                              ? Colors.red
                                              : CupertinoColors.activeBlue,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
