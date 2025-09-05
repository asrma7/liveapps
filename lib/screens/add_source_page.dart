import 'package:flutter/cupertino.dart';

class AddSourcePage extends StatefulWidget {
  const AddSourcePage({super.key});

  @override
  State<AddSourcePage> createState() => _AddSourcePageState();
}

class _AddSourcePageState extends State<AddSourcePage> {
  final TextEditingController _urlController = TextEditingController();

  // Dummy featured repos
  final List<Map<String, String>> featuredRepos = [
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "Add Source",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Save logic for manual source
            final url = _urlController.text.trim();
            if (url.isNotEmpty) {
              Navigator.pop(context, url);
            } else {
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.xmark),
        ),
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Source URL",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _urlController,
              placeholder: "Enter Source URL",
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 4),
            const Text(
              "The only supported repositories are AltStore repositories.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Import/Export
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      // Import logic
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(CupertinoIcons.arrow_down_circle),
                        SizedBox(width: 8),
                        Text("Import"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      // Export logic
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(CupertinoIcons.arrow_up_circle),
                        SizedBox(width: 8),
                        Text("Export"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Supports importing from KravaSign/MapleSign and ESign.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),

            const Text(
              "Featured",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            // Featured repos list
            ...featuredRepos.map((repo) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CupertinoListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      repo["iconUrl"]!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(repo["name"]!),
                  subtitle: Text(
                    repo["sourceURL"]!,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    onPressed: () {
                      Navigator.pop(context, repo["sourceURL"]);
                    },
                    child: const Text("Add"),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
