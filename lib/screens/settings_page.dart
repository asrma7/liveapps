import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;
  bool isLoading = true;
  late String liveContainerAppPath;

  @override
  void initState() {
    super.initState();
    fetchPreferences();
  }

  void fetchPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      liveContainerAppPath =
          prefs.getString('live_container_app_path') ?? 'Not Set';
      isLoading = false;
    });
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
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Version 1.0.0',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'This app is open source. Check it out on GitHub!',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    // Open GitHub link https://github.com/asrma7/liveapps
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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Text("Live Container App Path:"),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      String? result = await FilePicker.platform
                                          .getDirectoryPath();
                                      if (result != null) {
                                        await prefs.setString(
                                          'live_container_app_path',
                                          result,
                                        );
                                        setState(() {
                                          liveContainerAppPath = result;
                                        });
                                      }
                                    },
                                    child: Tooltip(
                                      message: liveContainerAppPath,
                                      child: Text(
                                        liveContainerAppPath,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
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
