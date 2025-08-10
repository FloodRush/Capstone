import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'favorites_page.dart';

class MotivationPage extends StatefulWidget {
  const MotivationPage({super.key});

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  final String apiKey = '2e6911b429771b543d931408ced6f86c';
  final List<Map<String, String>> quotes = [];
  final Set<int> favorites = {};
  final List<Map<String, String>> favoriteQuotes = [];
  int currentIndex = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    setState(() => loading = true);
    final res = await http.get(
      Uri.parse('https://favqs.com/api/qotd'),
      headers: {
        "Authorization": 'Token token="$apiKey"',
      },
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      quotes.add({
        "text": data['quote']['body'],
        "author": data['quote']['author'] ?? "Unknown",
      });
      setState(() {
        currentIndex = quotes.length - 1;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch quote")),
      );
    }
  }

  void nextQuote() {
    if (currentIndex < quotes.length - 1) {
      setState(() => currentIndex++);
    } else {
      fetchQuote();
    }
  }

  void previousQuote() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  void toggleFavorite() {
    setState(() {
      if (favorites.contains(currentIndex)) {
        favorites.remove(currentIndex);
        favoriteQuotes
            .removeWhere((q) => q["text"] == quotes[currentIndex]["text"]);
      } else {
        favorites.add(currentIndex);
        favoriteQuotes.add(quotes[currentIndex]);
      }
    });
  }

  void shareQuote() {
    final quote = quotes[currentIndex];
    Share.share('"${quote["text"]}" — ${quote["author"]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Motivation"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(
                    favorites: favoriteQuotes,
                    onRemoveFavorite: (index) {
                      setState(() {
                        final removedQuote = favoriteQuotes[index];
                        favoriteQuotes.removeAt(index);
                        favorites.removeWhere(
                            (i) => quotes[i]["text"] == removedQuote["text"]);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (quotes.isNotEmpty) _buildQuoteContent(),
          if (loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildQuoteContent() {
    final quote = quotes[currentIndex];
    final isFavorite = favorites.contains(currentIndex);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        key: ValueKey(currentIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      '"${quote["text"]}"',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                height: 1.4,
                                letterSpacing: 0.5,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "- ${quote["author"]}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: currentIndex > 0 ? previousQuote : null,
                  color: Theme.of(context).primaryColor,
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.pink : Colors.grey[600],
                  ),
                  onPressed: toggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: shareQuote,
                  color: Theme.of(context).primaryColor,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: nextQuote,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
