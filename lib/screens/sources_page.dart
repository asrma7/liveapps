import 'package:flutter/cupertino.dart';
import 'package:liveapps/screens/add_source_page.dart';
import 'package:liveapps/models/source.dart';
import 'package:liveapps/database_helper.dart';
import 'package:liveapps/screens/apps_page.dart';
import 'package:provider/provider.dart';
import 'package:liveapps/notifiers/apps_notifier.dart';
import 'package:liveapps/models/app.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  List<Source> sources = [];
  bool isLoading = true;
  bool isAddingSource = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchSources();
  }

  Future<void> fetchSources() async {
    final dbSources = await DatabaseHelper().database.then(
      (db) => db.query('sources'),
    );
    setState(() {
      sources = dbSources.map((e) => Source.fromMap(e)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSources = searchQuery.isEmpty
        ? sources
        : sources
              .where(
                (source) =>
                    source.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    source.sourceURL.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text("Sources"),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final url = await Navigator.push(
                  context,
                  CupertinoSheetRoute(
                    builder: (context) => const AddSourcePage(),
                  ),
                );
                if (url != null && url is String && url.isNotEmpty) {
                  final alreadyExists = sources.any((s) => s.sourceURL == url);
                  if (alreadyExists) {
                    if (context.mounted) {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text('Duplicate Source'),
                          content: const Text('This source already exists.'),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                    return;
                  }
                  setState(() {
                    isLoading = true;
                    isAddingSource = true;
                  });
                  try {
                    final response = await http.get(Uri.parse(url));
                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);
                      final newSource = Source(
                        name: data['name'] ?? 'Unknown',
                        identifier: data['identifier'] ?? url,
                        subtitle: data['subtitle'] ?? '',
                        sourceURL: url,
                        iconURL: data['iconURL'] ?? '',
                        website: data['website'] ?? '',
                      );
                      final db = await DatabaseHelper().database;
                      final sourceId = await db.insert(
                        'sources',
                        newSource.toMap(),
                      );
                      if (data['apps'] != null && data['apps'] is List) {
                        for (final appData in data['apps']) {
                          final app = App(
                            sourceId: sourceId,
                            name: appData['name'] ?? '',
                            bundleIdentifier: appData['bundleIdentifier'] ?? '',
                            version: appData['version'] ?? '',
                            versionDate: appData['versionDate'] ?? '',
                            downloadURL: appData['downloadURL'] ?? '',
                            localizedDescription:
                                appData['localizedDescription'] ?? '',
                            iconURL: appData['iconURL'] ?? '',
                            size: appData['size'] ?? 0,
                          );
                          await db.insert('apps', app.toMap());
                        }
                      }
                      if (context.mounted) {
                        try {
                          final provider = Provider.of<AppsNotifier>(
                            context,
                            listen: false,
                          );
                          await provider.refreshApps();
                        } catch (_) {}
                      }
                    } else {
                      if (context.mounted) {
                        showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text('Error'),
                            content: Text(
                              'Failed to fetch source data (status ${response.statusCode})',
                            ),
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
                  } catch (e) {
                    if (context.mounted) {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text('Error'),
                          content: Text(
                            'Failed to fetch or parse source data.',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  } finally {
                    await fetchSources();
                    setState(() {
                      isAddingSource = false;
                    });
                  }
                }
              },
              child: isAddingSource
                  ? const CupertinoActivityIndicator()
                  : const Icon(
                      CupertinoIcons.add,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Repositories',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    filteredSources.length.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final source = filteredSources[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: CupertinoListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            source.iconURL,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(source.name),
                        subtitle: Text(
                          source.sourceURL,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        trailing: const Icon(
                          CupertinoIcons.chevron_forward,
                          color: CupertinoColors.systemGrey,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => AppsPage(source: source),
                          ),
                        ),
                      ),
                    );
                  }, childCount: filteredSources.length),
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
