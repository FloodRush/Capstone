import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, String>> favorites = [];
  String? userId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    User? user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists && doc.data()?['favoriteQuotes'] != null) {
        List<dynamic> favs = doc.data()!['favoriteQuotes'];
        favorites = favs
            .map(
              (q) => {
                "text": q["text"]?.toString() ?? "",
                "author": q["author"]?.toString() ?? "Unknown",
              },
            )
            .toList();
      }
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _removeFavorite(int index) async {
    if (userId == null) return;
    setState(() {
      favorites.removeAt(index);
    });
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'favoriteQuotes': favorites,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quotes'),
        centerTitle: true,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(child: Text('No favorite quotes yet'))
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
                              onPressed: () => _removeFavorite(index),
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
