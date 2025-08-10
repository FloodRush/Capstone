import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class FavoritesPage extends StatelessWidget {
  final List<Map<String, String>> favorites;
  final Function(int) onRemoveFavorite;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quotes'),
        centerTitle: true,
        elevation: 0,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text('No favorite quotes yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final quote = favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      '"${quote["text"]}"',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "- ${quote["author"]}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            Share.share(
                                '"${quote["text"]}" — ${quote["author"]}');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onRemoveFavorite(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
