import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/love_page.dart';
import '../pages/product_details_page.dart';
import '../services/ai_service.dart';
import '../data/products.dart';
import '../models/product.dart';

class SirelleChatPage extends StatefulWidget {
  const SirelleChatPage({super.key});

  @override
  State<SirelleChatPage> createState() => _SirelleChatPageState();
}

class _SirelleChatPageState extends State<SirelleChatPage> {
  int _extractBudget(String text) {
    final match = RegExp(r'(\d{3,5})').firstMatch(text);
    return match != null ? int.parse(match.group(0)!) : 2000;
  }

  String? _extractCategory(String text) {
    if (text.contains('romantic')) return 'romantic';
    if (text.contains('gift')) return 'gift';
    if (text.contains('beauty')) return 'beauty';
    if (text.contains('lifestyle')) return 'lifestyle';
    return null;
  }

  String? _extractVibe(String text) {
    if (text.contains('cute')) return 'cute';
    if (text.contains('luxury')) return 'luxury';
    if (text.contains('romantic')) return 'romantic';
    if (text.contains('aesthetic')) return 'aesthetic';
    return null;
  }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatMemoryKey);
  }

  @override
  void initState() {
    super.initState();
    _initChat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _initChat() async {
    await _loadChatHistory();
    await _loadMemory();

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

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
    // Ensure scroll after all post frame callbacks and rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
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

  bool _shouldShowProducts(String text) {
    final t = text.toLowerCase();
    return t.contains('show') ||
        t.contains('recommend') ||
        t.contains('suggest') ||
        t.contains('gift') ||
        t.contains('products') ||
        t.contains('under') ||
        t.contains('below') ||
        t.contains('budget');
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _isTyping = true;
    });
    // Persist any existing memory values (intent, budget, vibe)
    await _saveMemory();
    _saveChatHistory();
    _scrollToBottom();

    _controller.clear();

    String aiReply;
    try {
      aiReply = await AiService.sendMessage(text);
    } catch (e) {
      aiReply = "⚠️ I’m having trouble connecting right now. Please try again.";
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }

    setState(() {
      _messages.add(_ChatMessage.bot(aiReply));

      // If user intent is product-related, show recommendations
      if (_shouldShowProducts(text)) {
        _messages.add(
          _ChatMessage.bot("✨ Picks just for you"),
        );
      }
    });

    _saveChatHistory();
    _scrollToBottom();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pink.shade50,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade300,
                    Colors.pink.shade500,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sirelle-chan",
                  style: TextStyle(
                    color: Colors.pink.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _isTyping ? "typing…" : "Online",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.pink.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.pink.shade700),
            onPressed: () {
              _clearChatHistory();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _quickActions(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 12),
                      child: _TypingBubble(),
                    );
                  }
                  final m = _messages[index];
                  if (index == 0) {
                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "Today",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.pink.shade300,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        m.isUser ? _UserBubble(text: m.text) : _BotBubble(text: m.text),
                        if (!m.isUser && m.text.contains("✨ Picks"))
                          _ProductList(
                            budget: _extractBudget(_messages.last.text.toLowerCase()),
                            category: _extractCategory(_messages.last.text.toLowerCase()),
                            vibe: _extractVibe(_messages.last.text.toLowerCase()),
                          ),
                      ],
                    );
                  }
                  return TweenAnimationBuilder<Offset>(
                    tween: Tween(begin: const Offset(0, 0.2), end: Offset.zero),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    builder: (context, offset, child) {
                      return Transform.translate(
                        offset: Offset(0, offset.dy * 40),
                        child: child,
                      );
                    },
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
                            _ProductList(
                              budget: _extractBudget(_messages.last.text.toLowerCase()),
                              category: _extractCategory(_messages.last.text.toLowerCase()),
                              vibe: _extractVibe(_messages.last.text.toLowerCase()),
                            ),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
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
                            color: Colors.pink.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
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
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade400,
              Colors.pink.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
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




class _ProductList extends StatelessWidget {
  final int budget;
  final String? category;
  final String? vibe;

  _ProductList({
    Key? key,
    required this.budget,
    this.category,
    this.vibe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter real products by budget only (Product has no category/vibe)
    final filtered = products
        .where((p) => p.price <= budget)
        .toList()
      ..shuffle();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          "No products found under your budget 💔",
          style: TextStyle(
            color: Colors.pink.shade400,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );
    }

    return Column(
      children: filtered.take(3).map((p) {
        return _ProductChatCardDynamic(product: p);
      }).toList(),
    );
  }
}

class _ProductChatCardDynamic extends StatelessWidget {
  final Product product;
  const _ProductChatCardDynamic({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.pink.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                product.thumbnail,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    "Aesthetic pick just for you ✨",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("₹${product.price}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product.name} added to cart 💗"),
                          backgroundColor: Colors.pink.shade400,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      "Add to cart",
                      style: TextStyle(
                        color: Colors.pink.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
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

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final opacity = ((_c.value + index * 0.3) % 1.0);
            return Opacity(
              opacity: opacity,
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.pink.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
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