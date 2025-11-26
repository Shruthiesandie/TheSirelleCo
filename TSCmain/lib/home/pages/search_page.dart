import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> dummyProducts = [
    "Pink Bunny Plush",
    "Matcha Mug",
    "Kawaii Keychain",
    "Cute Stationery",
    "Soft Blanket",
    "Pastel Hoodie"
  ];

  List<String> searchResults = [];

  void _search(String query) {
    setState(() {
      searchResults = dummyProducts
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFF8), // pastel matcha
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Search 🔍",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: _search,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search for cute items...",
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Search Results
            Expanded(
              child: searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        "Start typing to search ✨",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.star,
                                color: Colors.pinkAccent),
                            title: Text(searchResults[index]),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
