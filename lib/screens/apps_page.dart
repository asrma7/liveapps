import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:liveapps/models/app.dart';
import 'package:liveapps/models/source.dart';
import 'package:provider/provider.dart';
import 'package:liveapps/notifiers/apps_notifier.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppsPage extends StatefulWidget {
  final Source? source;
  const AppsPage({super.key, this.source});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  Map<int, double> downloadProgress = {};
  late SharedPreferences prefs;
  String searchQuery = "";
  late String sortType;
  late bool sortAscending;
  String? liveContainerAppPath;
  bool isReady = false;

  List<AppWithSourceIcon> displayedApps = [];

  @override
  void initState() {
    super.initState();
    fetchPreferences();
  }

  void fetchPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      sortType = prefs.getString('sort_type') ?? "default";
      sortAscending = prefs.getBool('sort_ascending') ?? false;
      liveContainerAppPath = prefs.getString('live_container_app_path');
      isReady = true;
    });
  }

  void setSortPreferences(String sortType, bool sortAscending) async {
    await prefs.setString('sort_type', sortType);
    await prefs.setBool('sort_ascending', sortAscending);
    setState(() {
      this.sortType = sortType;
      this.sortAscending = sortAscending;
      updateDisplayedApps();
    });
  }

  void updateDisplayedApps({AppsNotifier? notifier}) {
    final appsNotifier = notifier ?? context.read<AppsNotifier>();
    final allApps = widget.source == null
        ? appsNotifier.apps
        : appsNotifier.apps
              .where((app) => app.sourceId == widget.source!.id)
              .toList();

    final filteredApps = searchQuery.isEmpty
        ? allApps
        : allApps
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

    filteredApps.sort((a, b) {
      int comparison = 0;
      if (sortType == "name") {
        comparison = a.name.compareTo(b.name);
      } else if (sortType == "date" || sortType == "default") {
        comparison = a.versionDate.compareTo(b.versionDate);
      }
      return sortAscending ? comparison : -comparison;
    });

    displayedApps = filteredApps;
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return Consumer<AppsNotifier>(
      builder: (context, appsNotifier, _) {
        if (displayedApps.isEmpty) {
          updateDisplayedApps(notifier: appsNotifier);
        }

        final isLoading = appsNotifier.isLoading;

        return CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  widget.source == null ? 'All Apps' : widget.source!.name,
                ),
                trailing: IconButton(
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                        title: const Text("Filter by"),
                        actions: [
                          _buildSortAction("default"),
                          _buildSortAction("name"),
                          _buildSortAction("date"),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
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
                      updateDisplayedApps();
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
                    "${displayedApps.length} Apps",
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
                        final app = displayedApps[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: CupertinoListTile(
                            leading: Stack(
                              children: [
                                Image.network(
                                  app.iconURL,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemBackground
                                          .withAlpha(200),
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                    child: Image.network(
                                      app.sourceIconURL,
                                      width: 14,
                                      height: 14,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
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
                                    onPressed: () {
                                      if (prefs.getString(
                                            'live_container_app_path',
                                          ) ==
                                          null) {
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (_) => CupertinoAlertDialog(
                                            title: const Text('Path Not Set'),
                                            content: const Text(
                                              'Please set the Live Container app path in settings before downloading.',
                                            ),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('OK'),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        _downloadApp(app, index);
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
                      }, childCount: displayedApps.length),
                    ),
            ],
          ),
        );
      },
    );
  }

  CupertinoContextMenuAction _buildSortAction(String type) {
    return CupertinoContextMenuAction(
      onPressed: () {
        setSortPreferences(type, sortType != type || !sortAscending);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type[0].toUpperCase() + type.substring(1)),
          if (sortType == type)
            Icon(
              sortAscending
                  ? Ionicons.chevron_up_circle_outline
                  : Ionicons.chevron_down_circle_outline,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
        ],
      ),
    );
  }

  void _downloadApp(App app, int index) async {
    final url = app.downloadURL;
    final fileName = url.split('/').last;
    final key = app.id ?? index;
    setState(() {
      downloadProgress[key] = 0.0;
    });
    try {
      if (liveContainerAppPath == null) {
        throw Exception("Live Container app path is not set.");
      }
      final savePath = "${liveContainerAppPath!}/$fileName".replaceAll(
        '.ipa',
        '.zip',
      );
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress[key] = received / total;
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
            title: const Text('Download Complete'),
            content: Text('Saved to $savePath'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
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
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
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
      height: maxExtent,
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
