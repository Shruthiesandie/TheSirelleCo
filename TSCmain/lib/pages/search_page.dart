import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  List<String> recentSearches = []; // Stores last 4 searches only

  void _addSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      // Remove duplicates
      recentSearches.remove(query);

      // Add new search to top
      recentSearches.insert(0, query);

      // Keep only 4
      if (recentSearches.length > 4) {
        recentSearches.removeLast();
      }
    });

    _controller.clear();
  }

  void _deleteSearch(String text) {
    setState(() {
      recentSearches.remove(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _beautifulSearchBox(),
      ),

      // ---------------- BODY ----------------
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- RECENT SEARCHES TITLE ----------
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 20),
            child: Text(
              "Recent Searches",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ---------- DYNAMIC RECENT SEARCH CHIPS ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: recentSearches.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "No recent searches",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
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
                          ),
                        )
                        .toList(),
                  ),
          ),

          const SizedBox(height: 30),

          // ---------- EMPTY STATE ----------
          Expanded(
            child: Opacity(
              opacity: 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Floating circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      size: 70,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Start typing to search",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
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
            ),
          ),
        ],
      ),
    );
  }

  // 🌸 BEAUTIFUL SEARCH BOX
  Widget _beautifulSearchBox() {
    return Container(
      height: 35,
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
            color: Colors.pinkAccent.withOpacity(0.18),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.black54, size: 24),
          const SizedBox(width: 10),

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
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Submit arrow
          GestureDetector(
            onTap: () => _addSearch(_controller.text),
            child: const Icon(Icons.arrow_upward,
                size: 22, color: Colors.pinkAccent),
          ),
        ],
      ),
    );
  }
}

// ---------------- SEARCH CHIP WITH DELETE BUTTON ----------------
class SearchChip extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;

  const SearchChip({
    super.key,
    required this.text,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),

          // ❌ DELETE BUTTON
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
