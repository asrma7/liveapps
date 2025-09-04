import 'package:flutter/cupertino.dart';
import '../widgets/search_bar.dart';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  final TextEditingController _urlController = TextEditingController();

  // Dummy data for repositories
  List<Map<String, String>> sources = [
    {
      "iconUrl": "https://repo.cypwn.xyz/assets/images/cypwn_small.png",
      "name": "CyPwn IPA Library",
      "sourceURL": "https://ipa.cypwn.xyz/cypwn.json",
    },
    {
      "iconUrl":
          "https://apptesters.org/wp-content/uploads/2024/04/AppTesters-Logo-Site-Icon.webp",
      "name": "AppTesters IPA Repo",
      "sourceURL": "https://repository.apptesters.org/",
    },
  ];

  void _showAddSourceDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Add Source URL'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: _urlController,
              placeholder: 'Enter Repository URL',
              keyboardType: TextInputType.url,
              autocorrect: false,
              autofocus: true,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _urlController.clear();
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                final url = _urlController.text.trim();
                if (url.isNotEmpty) {
                  setState(() {
                    sources.add({
                      "iconUrl":
                          "https://repo.cypwn.xyz/assets/images/cypwn_small.png",
                      "name": "New Repo",
                      "sourceURL": url,
                    });
                  });
                }
                Navigator.of(context).pop();
                _urlController.clear();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: const Text(
          "Sources",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 38),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showAddSourceDialog,
          child: const Icon(CupertinoIcons.add),
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
                child: CupertinoScrollbar(
                  child: ListView.builder(
                    itemCount: sources.length,
                    itemBuilder: (context, index) {
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
                              source["iconUrl"]!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(source["name"]!),
                          subtitle: Text(
                            source["sourceURL"]!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          onTap: () {
                            // Optional: handle tap on repository
                          },
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
