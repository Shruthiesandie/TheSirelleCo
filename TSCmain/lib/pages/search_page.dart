import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7D9DA),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: const TextField(
            autofocus: true,
            cursorColor: Colors.pinkAccent,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search products...",
              hintStyle: TextStyle(
                color: Colors.black45,
                fontSize: 15,
              ),
              icon: Icon(Icons.search, color: Colors.black54, size: 22),
            ),
          ),
        ),
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

          // ---------- TAG CHIPS ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                SearchChip(text: "Dresses"),
                SearchChip(text: "Men Shirts"),
                SearchChip(text: "Pink Tops"),
                SearchChip(text: "Unisex Hoodie"),
                SearchChip(text: "Perfume"),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ---------- EMPTY STATE ----------
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Soft floating circle BG
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
}

// ---------------- SEARCH CHIP ----------------
class SearchChip extends StatelessWidget {
  final String text;

  const SearchChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
