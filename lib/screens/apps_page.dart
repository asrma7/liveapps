import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:liveapps/notifiers/apps_notifier.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<AppsNotifier>(
      builder: (context, appsNotifier, _) {
        final apps = appsNotifier.apps;
        final isLoading = appsNotifier.isLoading;
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
                largeTitle: const Text("Apps"),
                trailing: CupertinoContextMenu(
                  actions: <Widget>[
                    CupertinoContextMenuAction(
                      onPressed: () {
                        appsNotifier.fetchApps();
                        Navigator.pop(context);
                      },
                      trailingIcon: CupertinoIcons.chevron_up,
                      child: const Text("Default"),
                    ),
                    CupertinoContextMenuAction(
                      onPressed: () {
                        appsNotifier.fetchApps();
                        Navigator.pop(context);
                      },
                      child: const Text("Name"),
                    ),
                    CupertinoContextMenuAction(
                      onPressed: () {
                        appsNotifier.fetchApps();
                        Navigator.pop(context);
                      },
                      child: const Text("Date"),
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
      },
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
