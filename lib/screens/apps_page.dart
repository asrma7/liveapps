import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/search_bar.dart';
import 'package:liveapps/models/app.dart';
import 'package:liveapps/database_helper.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  List<App> apps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApps();
  }

  Future<void> fetchApps() async {
    final dbApps = await DatabaseHelper().getApps();
    setState(() {
      apps = dbApps.map((e) => App.fromMap(e)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        leading: Text(
          "Apps",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
        ),
        border: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: AppSearchBar(),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : CupertinoScrollbar(
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
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    app.iconURL,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(app.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Version: ${app.version}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                    Text(
                                      app.localizedDescription,
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
      ),
    );
  }
}
