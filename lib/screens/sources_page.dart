import 'package:flutter/cupertino.dart';
import 'package:liveapps/screens/add_source_page.dart';
import 'package:liveapps/models/source.dart';
import 'package:liveapps/database_helper.dart';
import 'package:liveapps/models/app.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:liveapps/widgets/search_bar_delegate.dart';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  List<Source> sources = [];
  bool isLoading = true;
  bool isAddingSource = false;

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
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          /// Sliver navigation bar (collapses/hides on scroll)
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
              child: Icon(
                isAddingSource ? CupertinoIcons.refresh : CupertinoIcons.add,
                color: CupertinoColors.activeBlue,
              ),
            ),
            border: null,
          ),

          /// Pinned search bar
          SliverPersistentHeader(pinned: true, delegate: SearchBarDelegate()),

          /// "Repositories" header + count
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
                    sources.length.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// List of sources
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final source = sources[index];
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
                      ),
                    );
                  }, childCount: sources.length),
                ),
        ],
      ),
    );
  }
}
