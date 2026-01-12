import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/love_page.dart';
import '../pages/cart_page.dart';
import '../pages/allcategories_page.dart';

class SirelleChatPage extends StatefulWidget {
  const SirelleChatPage({super.key});

  @override
  State<SirelleChatPage> createState() => _SirelleChatPageState();
}

class _SirelleChatPageState extends State<SirelleChatPage> {
  static const String _chatMemoryKey = 'sirelle_chat_messages';
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage.bot("Hey love ✨ I’m Sirelle-chan.\nReady to find something beautiful today?"),
  ];
  bool _isTyping = false;
  String? _lastIntent;
  String? _budget;
  String? _vibe;
  final ScrollController _scrollController = ScrollController();

  Future<void> _loadMemory() async {
    final prefs = await SharedPreferences.getInstance();
    _lastIntent = prefs.getString('lastIntent');
    _budget = prefs.getString('budget');
    _vibe = prefs.getString('vibe');
  }

  Future<void> _saveMemory() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastIntent != null) prefs.setString('lastIntent', _lastIntent!);
    if (_budget != null) prefs.setString('budget', _budget!);
    if (_vibe != null) prefs.setString('vibe', _vibe!);
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _messages
        .map((m) => '${m.isUser ? 'U' : 'B'}||${m.text}')
        .toList();
    await prefs.setStringList(_chatMemoryKey, data);
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_chatMemoryKey);
    if (stored == null || stored.isEmpty) return;

    setState(() {
      _messages
        ..clear()
        ..addAll(
          stored.map((e) {
            final parts = e.split('||');
            return parts.first == 'U'
                ? _ChatMessage.user(parts.last)
                : _ChatMessage.bot(parts.last);
          }),
        );
    });
  }

  Future<void> _clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatMemoryKey);
  }

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadMemory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastIntent != null) {
        setState(() {
          _messages.add(
            _ChatMessage.bot(
              "Welcome back 💗 Last time we were chatting about $_lastIntent${_budget != null ? " under $_budget" : ""}. Want to continue?"
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _isTyping = true;
    });
    _saveChatHistory();
    _scrollToBottom();

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add(_ChatMessage.bot(_botReply(text)));
        _isTyping = false;
      });
      _saveChatHistory();
      _scrollToBottom();
    });
  }

  String _botReply(String userText) {
    final t = userText.toLowerCase();

    int pick(List<String> list) =>
        DateTime.now().millisecondsSinceEpoch % list.length;

    // --- Intent chaining for dynamic product cards ---
    if (_lastIntent == "gift" && _budget != null && !_messages.last.text.contains("✨ Picks")) {
      Future.microtask(_insertProductCards);
    }

    // --- Detect budget ---
    if (t.contains("₹") || t.contains("rs") || t.contains("budget")) {
      _budget = userText;
      _lastIntent = "budget";
      _saveMemory();
      return [
        "Got it 💗 I’ll stay within that.",
        "Perfect ✨ That helps a lot.",
        "Noted 💕 Want something cute, elegant, or premium?"
      ][pick([
        "a","b","c"
      ])];
    }

    // --- Gift intent ---
    if (t.contains("gift")) {
      _lastIntent = "gift";
      _saveMemory();
      return [
        "Gifting mood 🎁 Who are we shopping for?",
        "Aww I love gift shopping 💗 What’s the occasion?",
        "Okayyy gifts ✨ Tell me your budget?"
      ][pick([
        "a","b","c"
      ])];
    }

    // --- Vibe detection ---
    if (t.contains("cute") || t.contains("elegant") || t.contains("premium")) {
      _vibe = userText;
      _lastIntent = "vibe";
      _saveMemory();
      return [
        "That vibe is lovely ✨",
        "Ooo great choice 💕",
        "Perfect taste 🤍 I have ideas."
      ][pick([
        "a","b","c"
      ])];
    }

    // --- Wishlist ---
    if (t.contains("wishlist")) {
      _lastIntent = "wishlist";
      _saveMemory();
      return [
        "Your wishlist has good taste 💗",
        "I peeked at your wishlist 👀 It’s cute.",
        "Want to move something from wishlist to cart?"
      ][pick([
        "a","b","c"
      ])];
    }

    // --- Cart ---
    if (t.contains("cart")) {
      _lastIntent = "cart";
      _saveMemory();
      return [
        "Your cart is waiting 🛍",
        "Almost there ✨ Want help choosing the final one?",
        "Shall we review your cart together?"
      ][pick([
        "a","b","c"
      ])];
    }

    // --- Greetings ---
    if (t.contains("hi") || t.contains("hello")) {
      _saveMemory();
      return [
        "Hey love ✨ What are we shopping for today?",
        "Hi 💗 Tell me your vibe today.",
        "Hello 🤍 Ready to find something beautiful?"
      ][pick([
        "a","b","c"
      ])];
    }

    // --- Dynamic product cards for gift + budget ---
    if (_lastIntent == "gift" && _budget != null) {
      Future.microtask(_insertProductCards);
    }

    // --- Contextual follow-ups ---
    if (_lastIntent == "gift") {
      _saveMemory();
      return "Still thinking about that gift 🎁 Tell me who it’s for.";
    }

    if (_lastIntent == "cart") {
      _saveMemory();
      return "Your cart is still open 🛍 Want help deciding?";
    }

    if (_lastIntent == "wishlist") {
      _saveMemory();
      return "Your wishlist is calling 💕 Want to pick one?";
    }

    // --- Default ---
    _saveMemory();
    return [
      "I’m listening 💗 Tell me more.",
      "Hmm okay ✨ go on.",
      "That sounds interesting 🤍"
    ][pick([
      "a","b","c"
    ])];
  }

  Widget _quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          _QuickActionChip(
            label: "Show gifts",
            onTap: () {
              setState(() {
                _messages.add(_ChatMessage.bot("Here are some lovely gift ideas 💝"));
              });
            },
          ),
          _QuickActionChip(
            label: "Open wishlist",
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LovePage()));
            },
          ),
        ],
      ),
    );
  }

  void _insertProductCards() {
    setState(() {
      _messages.add(_ChatMessage.bot("✨ Picks just for you"));
    });
    _saveChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1.1),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.pink.shade200,
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Sirelle-chan",
                  style: TextStyle(
                    color: Colors.pink.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            _isTyping ? _TypingDots() : Text(
              "Online",
              style: TextStyle(fontSize: 12, color: Colors.pink.shade400),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.pink.shade700),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _clearChatHistory();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _quickActions(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 12),
                    child: _TypingBubble(),
                  );
                }
                final m = _messages[index];
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                    key: ValueKey(m.text + index.toString()),
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        m.isUser
                            ? _UserBubble(text: m.text)
                            : _BotBubble(text: m.text),
                        if (!m.isUser && m.text.contains("✨ Picks"))
                          _ProductList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask Sirelle-chan something cute…",
                      hintStyle: TextStyle(color: Colors.pink.shade300),
                      filled: true,
                      fillColor: Colors.pink.shade50,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.pink.shade400,
                          Colors.pink.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotBubble extends StatelessWidget {
  final String text;
  const _BotBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(6),
            topLeft: Radius.circular(22),
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}



// --- Dynamic product model and product list widget ---
class ChatProduct {
  final String name;
  final String price;
  final String description;
  final IconData icon;
  ChatProduct(this.name, this.price, this.description, this.icon);
}

class _ProductList extends StatelessWidget {
  final List<ChatProduct> products = [
    ChatProduct("Pink Ceramic Mug", "₹799", "Perfect for cozy mornings ✨", Icons.local_cafe),
    ChatProduct("Rose Candle Set", "₹999", "Soft romantic glow 🕯", Icons.auto_awesome),
    ChatProduct("Gift Box Mini", "₹599", "Cute & elegant 🎁", Icons.card_giftcard),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products.map((p) {
        return _ProductChatCardDynamic(product: p);
      }).toList(),
    );
  }
}

class _ProductChatCardDynamic extends StatelessWidget {
  final ChatProduct product;
  const _ProductChatCardDynamic({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(product.icon, color: Colors.pink, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(product.description),
                const SizedBox(height: 6),
                Text(product.price, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage._(this.text, this.isUser);

  factory _ChatMessage.user(String text) => _ChatMessage._(text, true);
  factory _ChatMessage.bot(String text) => _ChatMessage._(text, false);
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _a = Tween(begin: 0.3, end: 1.0).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: const Text("typing…", style: TextStyle(color: Colors.pink)),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.pink,
        ),
      ),
      backgroundColor: Colors.pink.shade50,
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _TypingDots(),
      ),
    );
  }
}