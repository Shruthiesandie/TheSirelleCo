Widget _premiumOfferRibbon() {
    List<String> offers = [
      "💗 Flat 10% OFF on ₹1000+ orders",
      "✨ 20% OFF on ₹4000+ purchases",
      "⭐ Members get extra 5% cashback",
      "🚚 Free Delivery on prepaid orders",
    ];

    return SizedBox(
      height: 42,
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: const [0.0, 0.15, 0.85, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 9999,
          itemBuilder: (_, i) {
            String offer = offers[i % offers.length];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.85),
                    Colors.pinkAccent.withOpacity(0.40),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.18),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                offer,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.pink.shade800,
                ),
              ),
            );
          },
        ),
      ),
    );
  }