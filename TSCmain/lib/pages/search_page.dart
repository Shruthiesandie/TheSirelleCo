// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'dart:math';
import 'package:flutter/material.dart';
import '../data/products.dart';
import '../pages/product_details_page.dart';

import '../models/product.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  List<String> recentSearches = [];

  late AnimationController bgController;

  @override
  void initState() {
    super.initState();

    bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    bgController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Add search item
  void _addSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      recentSearches.remove(q);
      recentSearches.insert(0, q);
      if (recentSearches.length > 4) recentSearches.removeLast();
    });

    _controller.clear();
  }

  void _deleteSearch(String text) {
    setState(() => recentSearches.remove(text));
  }

  void _startVoiceSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🎤 Voice search coming soon..."),
        duration: Duration(seconds: 1),
      ),
    );
  }

  List<Product> _searchProducts(String query) {
    final q = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.thumbnail.toLowerCase().contains(q);
    }).toList();
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
      height: 52,
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
              onSubmitted: (value) => _addSearch(value),
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

          // Submit arrow
          GestureDetector(
            onTap: () => _addSearch(_controller.text),
            child: const Icon(Icons.arrow_upward,
                size: 25, color: Colors.pinkAccent),
          ),
          const SizedBox(width: 8),

          // Microphone
          GestureDetector(
            onTap: _startVoiceSearch,
            child: const Icon(Icons.mic_rounded,
                size: 22, color: Colors.black87),
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
    return Scaffold(
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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
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
              // Recent title
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  "Recent Searches",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Recent search chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: recentSearches.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "No recent searches",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black45,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: recentSearches
                            .map(
                              (text) => SearchChip(
                                text: text,
                                onDelete: () => _deleteSearch(text),
                                onTap: () => _addSearch(text),
                              ),
                            )
                            .toList(),
                      ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: _controller.text.trim().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: bgController,
                              builder: (_, __) {
                                return Transform.scale(
                                  scale: 1 +
                                      sin(bgController.value * 2 * pi) * 0.03,
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12
                                              .withOpacity(0.06),
                                          blurRadius: 22,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.search_rounded,
                                          size: 70,
                                          color: Colors.pinkAccent),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              "Start typing to search",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Find products, outfits & more",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Builder(
                        builder: (_) {
                          final results =
                              _searchProducts(_controller.text);
                          if (results.isEmpty) {
                            return const Center(
                              child: Text(
                                "No products found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: results.length,
                            itemBuilder: (_, i) {
                              final p = results[i];
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    p.thumbnail,
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  p.thumbnail.split("/")[2]
                                      .replaceAll("_", " ")
                                      .toUpperCase(),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailsPage(product: p),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
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
