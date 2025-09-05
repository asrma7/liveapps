import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:liveapps/models/source.dart';
import 'package:liveapps/models/app.dart';
import 'package:liveapps/database_helper.dart';
import 'package:path_provider/path_provider.dart';

class SourceAppsPage extends StatefulWidget {
  final Source source;
  const SourceAppsPage({super.key, required this.source});

  @override
  State<SourceAppsPage> createState() => _SourceAppsPageState();
}

class _SourceAppsPageState extends State<SourceAppsPage> {
  List<App> apps = [];
  Map<int, double> downloadProgress = {};
  bool isLoading = true;
  String searchQuery = "";
  String sortType = "default";
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    fetchApps();
  }

  Future<void> fetchApps() async {
    final dbApps = await DatabaseHelper().getAppsBySource(widget.source.id!);
    setState(() {
      apps = dbApps.map((e) => App.fromMap(e)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = searchQuery.isEmpty
        ? apps
        : apps
              .where(
                (app) =>
                    app.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    app.localizedDescription.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    final sortedApps = filteredApps
      ..sort((a, b) {
        int comparison = 0;
        if (sortType == "name") {
          comparison = a.name.compareTo(b.name);
        } else if (sortType == "date" || sortType == "default") {
          comparison = a.versionDate.compareTo(b.versionDate);
        }
        return sortAscending ? comparison : -comparison;
      });
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(widget.source.name),
            trailing: CupertinoContextMenu(
              actions: <Widget>[
                CupertinoContextMenuAction(
                  onPressed: () {
                    setState(() {
                      if (sortType == "default") {
                        sortType = "default";
                        sortAscending = !sortAscending;
                      } else {
                        sortType = "default";
                        sortAscending = true;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Default"),
                      if (sortType == "default")
                        Icon(
                          sortAscending
                              ? Ionicons.chevron_up_circle_outline
                              : Ionicons.chevron_down_circle_outline,
                          size: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                    ],
                  ),
                ),
                CupertinoContextMenuAction(
                  onPressed: () {
                    setState(() {
                      sortType = "name";
                      sortAscending = !sortAscending;
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Name"),
                      if (sortType == "name")
                        Icon(
                          sortAscending
                              ? Ionicons.chevron_up_circle_outline
                              : Ionicons.chevron_down_circle_outline,
                          size: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                    ],
                  ),
                ),
                CupertinoContextMenuAction(
                  onPressed: () {
                    setState(() {
                      sortType = "date";
                      sortAscending = !sortAscending;
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Date"),
                      if (sortType == "date")
                        Icon(
                          sortAscending
                              ? Ionicons.chevron_up_circle_outline
                              : Ionicons.chevron_down_circle_outline,
                          size: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                    ],
                  ),
                ),
              ],
              child: const Icon(
                Ionicons.filter_outline,
                color: CupertinoColors.activeBlue,
              ),
            ),
            border: null,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                "${sortedApps.length} Apps",
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final app = sortedApps[index];
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
                        trailing:
                            downloadProgress[app.id ?? index] != null &&
                                downloadProgress[app.id ?? index]! < 1.0
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  value: downloadProgress[app.id ?? index],
                                  strokeWidth: 2.5,
                                ),
                              )
                            : CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  final url = app.downloadURL;
                                  final fileName = url.split('/').last;
                                  final key = app.id ?? index;
                                  setState(() {
                                    downloadProgress[key] = 0.0;
                                  });
                                  try {
                                    final dir =
                                        await getApplicationDocumentsDirectory();
                                    final savePath = '${dir.path}/$fileName';
                                    await Dio().download(
                                      url,
                                      savePath,
                                      onReceiveProgress: (received, total) {
                                        if (total != -1) {
                                          setState(() {
                                            downloadProgress[key] =
                                                received / total;
                                          });
                                        }
                                      },
                                    );
                                    setState(() {
                                      downloadProgress.remove(key);
                                    });
                                    if (context.mounted) {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (_) => CupertinoAlertDialog(
                                          title: const Text(
                                            'Download Complete',
                                          ),
                                          content: Text('Saved to $savePath'),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text('OK'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      downloadProgress.remove(key);
                                    });
                                    if (context.mounted) {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (_) => CupertinoAlertDialog(
                                          title: const Text('Download Failed'),
                                          content: Text(e.toString()),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text('OK'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Icon(
                                  Ionicons.download_outline,
                                  size: 24,
                                  color: CupertinoColors.activeBlue,
                                ),
                              ),
                      ),
                    );
                  }, childCount: sortedApps.length),
                ),
        ],
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String> onChanged;
  _SearchBarDelegate({required this.onChanged});

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        placeholder: "Search",
        onChanged: onChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
