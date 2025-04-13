import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class MotivationPage extends StatefulWidget {
  const MotivationPage({super.key});

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> {
  final String apiKey = '2e6911b429771b543d931408ced6f86c';
  final List<Map<String, String>> quotes = [];
  final Set<int> favorites = {};
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
      } else {
        favorites.add(currentIndex);
      }
    });
  }

  void shareQuote() {
    final quote = quotes[currentIndex];
    Share.share('"${quote["text"]}" — ${quote["author"]}');
  }

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty || loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final quote = quotes[currentIndex];
    final isFavorite = favorites.contains(currentIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Motivational Quote"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '"${quote["text"]}"',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "- ${quote["author"]}",
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: previousQuote,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: isFavorite ? Colors.pink : Colors.grey,
                  ),
                  onPressed: toggleFavorite,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: shareQuote,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: nextQuote,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
