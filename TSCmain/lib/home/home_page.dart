import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (selectedIndex == 0) _premiumRibbon(),
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: [
                      const HomeContent(),
                      _placeholder("Wishlist"),
                      _placeholder("Categories"),
                      _placeholder("Cart"),
                      _placeholder("Profile"),
                    ],
                  ),
                ),
              ],
            ),
            _floatingBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _floatingBottomNavBar() {
    List<IconData> icons = [
      Icons.home_rounded,
      Icons.favorite_rounded,
      Icons.grid_view_rounded,
      Icons.shopping_bag_rounded,
      Icons.person_rounded
    ];

    return Positioned(
      left: 20,
      right: 20,
      bottom: 10,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.82),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (i) {
            final active = i == selectedIndex;
            return GestureDetector(
              onTap: () => setState(() => selectedIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: active ? Colors.pink.shade50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  icons[i],
                  size: 26,
                  color: active ? Colors.pink.shade700 : Colors.pink.shade300,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _placeholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFFFE4E9),
            child: Text("✨", style: TextStyle(fontSize: 34)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontFamily: "Playfair Display",
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade900,
            ),
          ),
          Text(
            "Coming Soon",
            style: TextStyle(color: Colors.pink.shade400),
          ),
        ],
      ),
    );
  }

  /// === Premium Scrolling Ribbon ===
  Widget _premiumRibbon() {
    List<String> offers = [
      "💗 10% Off above ₹1000",
      "✨ 20% Off above ₹4000",
      "⭐ Members Get 5% Cashback",
      "🚚 Free Delivery Prepaid",
    ];

    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: offers.length * 4,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemBuilder: (_, i) {
          String offer = offers[i % offers.length];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.pinkAccent.withOpacity(.17),
                  Colors.white.withOpacity(.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(.15),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              offer,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.pink.shade800,
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ----------------------------------------------------------
   HOME CONTENT WITH ANIMATED UI
-----------------------------------------------------------*/

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: const [
          SizedBox(height: 10),
          SpotlightBanner(),
          SizedBox(height: 10),
          CategoriesSection(),
          SizedBox(height: 10),
          OfferCard(),
          SizedBox(height: 10),
          TrendingSection(),
        ],
      ),
    );
  }
}

/* ----------------------------------------------------------
   SPOTLIGHT / HERO BANNER
-----------------------------------------------------------*/

class SpotlightBanner extends StatefulWidget {
  const SpotlightBanner({super.key});

  @override
  State<SpotlightBanner> createState() => _SpotlightBannerState();
}

class _SpotlightBannerState extends State<SpotlightBanner> {
  int index = 0;

  final slides = [
    {"title": "Summer Luxe", "subtitle": "New Collection 2025", "emoji": "🌸"},
    {"title": "Elegant Evening", "subtitle": "Flat 30% Off", "emoji": "✨"},
    {"title": "Royal Bags", "subtitle": "Premium Leather", "emoji": "👜"},
  ];

  @override
  void initState() {
    super.initState();
    _loopSlides();
  }

  void _loopSlides() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      setState(() => index = (index + 1) % slides.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[index];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 900),
      child: Container(
        key: ValueKey(index),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade300,
              Colors.pink.shade100,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade200.withOpacity(.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -10,
              right: -10,
              child: Opacity(
                opacity: .25,
                child: Text(slide["emoji"]!, style: const TextStyle(fontSize: 100)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: const Text("Featured"),
                    backgroundColor: Colors.white.withOpacity(.25),
                    padding: EdgeInsets.zero,
                    labelStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide["title"]!,
                    style: const TextStyle(
                      fontFamily: "Playfair Display",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    slide["subtitle"]!,
                    style: TextStyle(
                        color: Colors.white.withOpacity(.9), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------
   CATEGORY CIRCLES
-----------------------------------------------------------*/

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  int selected = 0;

  final names = ["New In", "Clothing", "Shoes", "Bags", "Beauty", "Jewelry"];
  final emoji = ["✨", "👗", "👠", "👜", "💄", "💍"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: names.length,
        itemBuilder: (context, i) {
          bool active = selected == i;
          return GestureDetector(
            onTap: () => setState(() => selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              margin: const EdgeInsets.only(right: 14),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: active
                            ? [Colors.pink.shade300, Colors.white]
                            : [Colors.white, Colors.pink.shade50],
                      ),
                      border: Border.all(
                        width: active ? 2 : 1,
                        color: Colors.white,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(active ? .35 : .12),
                          blurRadius: active ? 14 : 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(emoji[i], style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    names[i],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.pink.shade900,
                      fontWeight:
                          active ? FontWeight.bold : FontWeight.w500,
                    ),
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

/* ----------------------------------------------------------
   OFFER / PREMIUM CARD
-----------------------------------------------------------*/

class OfferCard extends StatelessWidget {
  const OfferCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        image: const DecorationImage(
          image: NetworkImage(
              "https://images.unsplash.com/photo-1483985988355-763728e1935b"),
          fit: BoxFit.cover,
          opacity: .30,
        ),
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(.7), Colors.transparent],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(.15),
            blurRadius: 10,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(.25),
              child: const Text("💎"),
            ),
            const SizedBox(height: 12),
            const Text(
              "Premium Membership",
              style: TextStyle(
                fontFamily: "Playfair Display",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              "Unlock exclusive access to new collections.",
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
            const Spacer(),
            Text("Join Now →",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.pink.shade200,
                    decoration: TextDecoration.underline)),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------
   TRENDING GRID
-----------------------------------------------------------*/

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 210,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => _build(i),
    );
  }

  Widget _build(int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: Duration(milliseconds: 260 + index * 100),
      curve: Curves.easeOutBack,
      builder: (_, val, child) =>
          Transform.scale(scale: val as double, child: child),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade200.withOpacity(.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(child: Text("👜", style: TextStyle(fontSize: 38, color: Colors.black26))),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Luxury Bag ${index + 1}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹2,499",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.pink.shade900)),
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.pink.shade50,
                        child: Text("+",
                            style: TextStyle(
                                fontSize: 18, color: Colors.pink.shade900)),
                      )
                    ],
                  )
                ],
              ),
            ),
            if (index == 0)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink.shade500,
                        Colors.pink.shade300,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("NEW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}