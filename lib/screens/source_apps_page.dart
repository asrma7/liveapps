import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:liveapps/models/source.dart';
import 'package:liveapps/models/app.dart';
import 'package:liveapps/database_helper.dart';

class SourceAppsPage extends StatefulWidget {
  final Source source;
  const SourceAppsPage({super.key, required this.source});

  @override
  State<SourceAppsPage> createState() => _SourceAppsPageState();
}

class _SourceAppsPageState extends State<SourceAppsPage> {
  List<App> apps = [];
  bool isLoading = true;
  String searchQuery = "";

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
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(widget.source.name),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // Filter Apps
              },
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
                "${filteredApps.length} Apps",
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
                    final app = filteredApps[index];
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
                  }, childCount: filteredApps.length),
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
