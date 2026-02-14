// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/product_details_page.dart';
import '../models/product.dart';
import '../controllers/favorites_controller.dart';
import '../services/behavior_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  // Zara-style shrinking search bar scroll controller and height
  final ScrollController _scrollController = ScrollController();
  double _searchBarHeight = 52;

  List<String> recentSearches = [];
  List<Product> recentlyViewed = [];

  late AnimationController bgController;

  List<Product> _results = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Wishlist state
  List<Product> wishlistItems = [];
  bool _wishlistLoading = true;

  // UI idle state helpers
  bool get _isIdle => _controller.text.trim().isEmpty;
  bool get _hasResults => _controller.text.trim().isNotEmpty && _results.isNotEmpty;

  // --- Persistence helpers ---
  static const String _recentSearchesKey = 'recent_searches';
  static const String _recentlyViewedKey = 'recently_viewed';
  static const int _maxRecentSearches = 5;
  static const int _maxRecentlyViewed = 6;

  @override
  void initState() {
    super.initState();
    // 🔥 AI Behavior Log — Search page opened
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      BehaviorLogger.log(
        userId: user.uid,
        screenName: "search_page",
        actionType: "navigation",
        actionValue: "open",
      );
    }

    _scrollController.addListener(() {
      final offset = _scrollController.offset;

      setState(() {
        _searchBarHeight = offset > 10 ? 44 : 52;
      });
    });

    bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _loadRecentSearches();
    _loadRecentlyViewed();
    _loadWishlist();
    FavoritesController.items.addListener(() {
      if (!mounted) return;
      setState(() {
        wishlistItems = List<Product>.from(FavoritesController.items.value);
      });
    });
  }

  Future<void> _loadWishlist() async {
    try {
      await FavoritesController.loadForCurrentUser();
      setState(() {
        wishlistItems = List<Product>.from(FavoritesController.items.value);
        _wishlistLoading = false;
      });
    } catch (e) {
      _wishlistLoading = false;
    }
  }

  @override
  void dispose() {
    bgController.dispose();
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? loaded = prefs.getStringList(_recentSearchesKey);
    if (loaded != null) {
      setState(() {
        recentSearches = List<String>.from(loaded);
      });
    }
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  Future<void> _loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? loaded = prefs.getStringList(_recentlyViewedKey);
    if (loaded != null) {
      setState(() {
        recentlyViewed = loaded.map((e) {
          try {
            return Product.fromJson(jsonDecode(e));
          } catch (_) {
            return null;
          }
        }).whereType<Product>().toList();
      });
    }
  }

  Future<void> _saveRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> toSave = recentlyViewed.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_recentlyViewedKey, toSave);
  }

  Future<void> _addRecentlyViewed(Product p) async {
    setState(() {
      recentlyViewed.removeWhere((item) => item.uiId == p.uiId);
      recentlyViewed.insert(0, p);
      if (recentlyViewed.length > _maxRecentlyViewed) {
        recentlyViewed = recentlyViewed.sublist(0, _maxRecentlyViewed);
      }
    });
    await _saveRecentlyViewed();
  }

  // Add search item
  void _addSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      recentSearches.remove(q);
      recentSearches.insert(0, q);
      if (recentSearches.length > _maxRecentSearches) {
        recentSearches = recentSearches.sublist(0, _maxRecentSearches);
      }
    });
    _saveRecentSearches();
    // Do NOT clear controller automatically
  }

  void _deleteSearch(String text) {
    setState(() => recentSearches.remove(text));
    _saveRecentSearches();
  }

  void _startVoiceSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🎤 Voice search coming soon..."),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _searchFromBackend(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final res = await http.get(
        Uri.parse('http://127.0.0.1:3000/search?q=$q'),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _results = data.map((e) => Product.fromJson(e)).toList();
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
      }
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  // ------------------------------------------------------------
  // ORB WIDGET
  // ------------------------------------------------------------
  Widget _orb(double x, double y, double size, Color color) {
    return Positioned(
      left: x * MediaQuery.of(context).size.width,
      top: y * MediaQuery.of(context).size.height,
      child: AnimatedBuilder(
        animation: bgController,
        builder: (_, __) {
          final t = bgController.value;
          final dx = sin(t * 2 * pi) * 8;
          final dy = cos(t * 2 * pi) * 8;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.30),
                    blurRadius: 60,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // PREMIUM SEARCH BOX
  // ------------------------------------------------------------
  Widget _beautifulSearchBox() {
    return AnimatedContainer(
      margin: const EdgeInsets.only(top: 8, bottom: 6),
      duration: const Duration(milliseconds: 350),
      height: _searchBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF9D7DD),
            Color(0xFFFCEEEE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.black54, size: 24),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              cursorColor: Colors.pinkAccent,
              onChanged: (value) {
                _debounce?.cancel();

                if (value.trim().isEmpty) {
                  setState(() {
                    _results = [];
                    _isSearching = false;
                  });
                  return;
                }

                _debounce = Timer(const Duration(milliseconds: 350), () {
                  _searchFromBackend(value);
                  // 🔥 AI Behavior Log — user typing search
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    BehaviorLogger.log(
                      userId: user.uid,
                      screenName: "search_page",
                      actionType: "typing",
                      actionValue: value,
                    );
                  }
                });
              },
              onSubmitted: (value) {
                _addSearch(value);
                _searchFromBackend(value); // 🔥 FIX: trigger search when pressing Enter

                // 🔥 AI Behavior Log — search submitted
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  BehaviorLogger.log(
                    userId: user.uid,
                    screenName: "search_page",
                    actionType: "search",
                    actionValue: value,
                  );
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Search something cute...",
                hintStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          // Conditional clear/submit/microphone icons (UX update)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final hasText = value.text.trim().isNotEmpty;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasText)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() {
                          _results = [];
                          _isSearching = false;
                        });
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: () {
                      if (hasText) {
                        final text = value.text;
                        _addSearch(text);
                        _searchFromBackend(text);

                        // 🔥 AI Behavior Log — search submitted (arrow tap)
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          BehaviorLogger.log(
                            userId: user.uid,
                            screenName: "search_page",
                            actionType: "search",
                            actionValue: text,
                          );
                        }
                      }
                    },
                    child: const Icon(
                      Icons.arrow_upward,
                      size: 24,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: _startVoiceSearch,
                    child: const Icon(
                      Icons.mic_rounded,
                      size: 22,
                      color: Colors.black87,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),

      // ------------------------------------------------------------
      // PREMIUM APP BAR
      // ------------------------------------------------------------
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 3,
        shadowColor: Colors.pinkAccent.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () async {
            final shouldPop = await _handleBackNavigation();
            if (shouldPop) {
              Navigator.pop(context);
            }
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4, right: 6, left: 2),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.98,
            child: _beautifulSearchBox(),
          ),
        ),
      ),

      // ------------------------------------------------------------
      // BACKGROUND ORBS + CONTENT
      // ------------------------------------------------------------
      body: Stack(
        children: [
          // Floating orbs
          _orb(0.15, 0.20, 110, Colors.pinkAccent.withOpacity(0.25)),
          _orb(0.75, 0.10, 130, Colors.purpleAccent.withOpacity(0.20)),
          _orb(0.40, 0.65, 160, Colors.pink.withOpacity(0.20)),

          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isIdle
                      ? _IdleContent(
                          recentSearches: recentSearches,
                          onRecentSearchTap: (String search) {
                            setState(() {
                              _controller.text = search;
                            });
                            _searchFromBackend(search);
                          },
                          onRecentSearchDelete: _deleteSearch,
                          recentlyViewed: recentlyViewed,
                          onProductTap: (Product p) async {
                            await _addRecentlyViewed(p);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsPage(product: p),
                              ),
                            );
                          },
                          wishlistItems: wishlistItems,
                          wishlistLoading: _wishlistLoading,
                          scrollController: _scrollController,
                        )
                      : _hasResults
                          ? _SearchResults(
                              results: _results,
                              onProductTap: (Product p) async {
                                await _addRecentlyViewed(p);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailsPage(product: p),
                                  ),
                                );
                              },
                              scrollController: _scrollController,
                            )
                          : _SearchSuggestions(
                              query: _controller.text.trim(),
                              isLoading: _isSearching,
                            ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
  );
}

  Future<bool> _handleBackNavigation() async {
    // If user is in search results or typing → go back to search home
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _controller.clear();
        _results = [];
        _isSearching = false;
      });
      return false; // prevent popping SearchPage
    }

    // If already on search home → allow pop to Home
    return true;
  }
}

// ------------------------------------------------------------
// SEARCH CHIP (Upgraded to glass, glow, elevation)
// ------------------------------------------------------------
class SearchChip extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const SearchChip({
    super.key,
    required this.text,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFFFF5F8)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close_rounded,
                  size: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// STATE UI HELPERS
// ------------------------------------------------------------

class _IdleContent extends StatelessWidget {
  final List<String> recentSearches;
  final void Function(String) onRecentSearchTap;
  final void Function(String) onRecentSearchDelete;
  final List<Product> recentlyViewed;
  final void Function(Product) onProductTap;
  final List<Product> wishlistItems;
  final bool wishlistLoading;
  final ScrollController scrollController;

  const _IdleContent({
    Key? key,
    required this.recentSearches,
    required this.onRecentSearchTap,
    required this.onRecentSearchDelete,
    required this.recentlyViewed,
    required this.onProductTap,
    required this.wishlistItems,
    required this.wishlistLoading,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 20),
      children: [
        if (recentSearches.isNotEmpty) ...[
          const _SectionTitle("Recent Searches"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches
                  .map((text) => SearchChip(
                        text: text,
                        onTap: () => onRecentSearchTap(text),
                        onDelete: () => onRecentSearchDelete(text),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
        ] else ...[
          const _SectionTitle("Recent Searches"),
          const _PlaceholderTile("No recent searches yet"),
          const SizedBox(height: 18),
        ],

        const _SectionTitle("Recently Viewed"),
        if (recentlyViewed.isNotEmpty)
          SizedBox(
            height: 195,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: recentlyViewed.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final p = recentlyViewed[i];
                return GestureDetector(
                  onTap: () => onProductTap(p),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.asset(
                            p.imageUrl,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${p.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else
          const _PlaceholderTile("Your viewed items appear here"),

        const SizedBox(height: 24),

        const _SectionTitle("Wishlist"),
        if (wishlistLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (wishlistItems.isEmpty)
          const _PlaceholderTile("No items in wishlist")
        else
          SizedBox(
            height: 195,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: wishlistItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final p = wishlistItems[i];
                return GestureDetector(
                  onTap: () => onProductTap(p),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.asset(
                            p.imageUrl,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${p.price}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final String query;
  final bool isLoading;

  const _SearchSuggestions({
    required this.query,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.pinkAccent,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 12),
      children: [
        _SectionTitle("Category"),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: Text("Results for \"$query\""),
        ),

        const SizedBox(height: 16),
        _SectionTitle("Products"),
        ...List.generate(
          5,
          (i) => ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: Text("$query item ${i + 1}"),
          ),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<Product> results;
  final Future<void> Function(Product)? onProductTap;
  final ScrollController scrollController;

  const _SearchResults({
    required this.results,
    this.onProductTap,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final p = results[i];
        return GestureDetector(
          onTap: () {
            if (onProductTap != null) {
              onProductTap!(p);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(
                      p.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          p.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "₹${p.price}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  final String text;
  const _PlaceholderTile(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black45),
        ),
      ),
    );
  }
}