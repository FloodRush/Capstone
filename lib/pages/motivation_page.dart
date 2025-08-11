import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'favorites_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

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
  String? currentBackgroundUrl;
  bool isImageLoading = true;
  final List<String> _imageUrlCache = [];
  final int _maxCacheSize = 5;
  bool _isFetchingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeImageCache();
    fetchQuote();
  }

  Future<void> _initializeImageCache() async {
    // Load initial set of images
    for (int i = 0; i < 2; i++) {
      await _fetchAndCacheImage();
    }
    if (_imageUrlCache.isNotEmpty) {
      setState(() {
        currentBackgroundUrl = _imageUrlCache.first;
        isImageLoading = false;
      });
    }
  }

  Future<void> _fetchAndCacheImage() async {
    if (_isFetchingImage) return;
    _isFetchingImage = true;

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.unsplash.com/photos/random?query=nature,calm,peaceful&orientation=portrait'),
        headers: {
          'Authorization':
              'Client-ID aUqrVlgxqc9M_ld_fUV42Ek4Axy9_jHnI_6W9blX7QI',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['urls']['regular'];

        if (!_imageUrlCache.contains(imageUrl)) {
          _imageUrlCache.add(imageUrl);
          // Keep cache size in check
          if (_imageUrlCache.length > _maxCacheSize) {
            _imageUrlCache.removeAt(0);
          }
        }
      }
    } catch (e) {
      print('Error pre-fetching image: $e');
    } finally {
      _isFetchingImage = false;
    }
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
    _updateBackground();
  }

  void _updateBackground() {
    if (_imageUrlCache.isEmpty) {
      _fetchAndCacheImage();
      return;
    }

    setState(() {
      if (_imageUrlCache.length > 1) {
        currentBackgroundUrl = _imageUrlCache[1];
        _imageUrlCache.removeAt(0);
      }
    });

    // Pre-fetch next image if cache is getting low
    if (_imageUrlCache.length < 3) {
      _fetchAndCacheImage();
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
        backgroundColor: Colors.transparent,
        title: const Text(
          "Daily Motivation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22, // Added larger font size
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white, // Changed icon color
              size: 28, // Added larger icon size
            ),
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          if (currentBackgroundUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: currentBackgroundUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) {
                  print('Error loading image: $error'); // Debug print
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Content
          if (quotes.isNotEmpty) _buildQuoteContent(),
          if (loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildQuoteContent() {
    final quote = quotes[currentIndex];
    final isFavorite = favorites.contains(currentIndex);

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          key: ValueKey(currentIndex),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                color: Colors.black.withOpacity(0.5),
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
                                  color: Colors.white,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "- ${quote["author"]}",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
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
                      color: isFavorite
                          ? Colors.pink
                          : Theme.of(context).primaryColor,
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
      ),
    );
  }
}
