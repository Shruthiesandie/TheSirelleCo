import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/love_page.dart';
import '../pages/product_details_page.dart';
import '../services/ai_service.dart';
import '../services/ai_learning_service.dart';
import '../data/products.dart';
import '../models/product.dart';

class SirelleChatPage extends StatefulWidget {
  const SirelleChatPage({super.key});

  @override
  State<SirelleChatPage> createState() => _SirelleChatPageState();
}

class _SirelleChatPageState extends State<SirelleChatPage> {

  // --- Virtual category mapping for friend groups
  static const Map<String, List<String>> _virtualCategoryMap = {
    'boy_friend': [
      'bottles',
      'caps',
      'key_chain',
      'ceramic',
    ],
    'girl_friend': [
      'candle',
      'hair_accessories',
      'plusie',
      'letter',
      'nails',
    ],
  };

  String? _activeCategory;
  int? _activeBudget;
  final Set<String> _shownProductIds = {};
  bool _showProducts = false;

  String? _extractCategory(String text) {
    // Remove non-letter characters for better fuzzy matching
    text = text.replaceAll(RegExp(r'[^a-z ]'), '');
    final words = text.split(RegExp(r'\s+'));
    for (final w in words) {
      final match = _fuzzyCategoryMatch(w);
      if (match != null) return match;
    }
    return null;
  }
  // Helper: determine category from product thumbnail
  String _productCategory(Product p) {
    final t = p.thumbnail.toLowerCase();
    if (t.contains('bottle')) return 'bottles';
    if (t.contains('candle')) return 'candle';
    if (t.contains('cap')) return 'caps';
    if (t.contains('letter')) return 'letter';
    if (t.contains('key')) return 'key_chain';
    if (t.contains('plush')) return 'plusie';
    if (t.contains('hair')) return 'hair_accessories';
    if (t.contains('ceramic') || t.contains('mug')) return 'ceramic';
    if (t.contains('nail')) return 'nails';
    // --- Added friend categories
    if (t.contains('boy_friend')) return 'boy_friend';
    if (t.contains('girl_friend')) return 'girl_friend';
    return 'unknown';
  }

  // --- Normalizes category names for matching
  String _normalizeCategory(String c) {
    switch (c) {
      case 'bottle':
      case 'bottles':
        return 'bottles';
      case 'cap':
      case 'caps':
        return 'caps';
      case 'letter':
      case 'letters':
        return 'letter';
      case 'candle':
      case 'candles':
        return 'candle';
      default:
        return c;
    }
  }

  // ---------- FUZZY MATCH HELPERS ----------
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[a.length][b.length];
  }

  String? _fuzzyCategoryMatch(String input) {
    const categoryMap = {
      'bottles': ['bottle', 'botle', 'botles', 'bottel'],
      'candle': ['candle', 'candl', 'candles'],
      'caps': ['cap', 'caps', 'capss'],
      'letter': ['letter', 'leter', 'letters'],
      'key_chain': ['keychain', 'key chain', 'keychan'],
      'plusie': ['plush', 'plushie', 'softtoy', 'soft toy'],
      'hair_accessories': ['hair', 'band', 'clip'],
      'ceramic': ['ceramic', 'cup', 'mug'],
      'nails': ['nail', 'nails'],
      // --- Appended friend categories
      'boy_friend': ['boy', 'boyfriend', 'bf', 'him'],
      'girl_friend': ['girl', 'girlfriend', 'gf', 'her'],
    };

    for (final entry in categoryMap.entries) {
      for (final keyword in entry.value) {
        if (_levenshtein(input, keyword) <= 2 ||
            input.contains(keyword) ||
            keyword.contains(input)) {
          return entry.key;
        }
      }
    }
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
  String? _vibe;
  Map<String, int> _vibeCounter = {};
  final ScrollController _scrollController = ScrollController();

  Future<void> _loadMemory() async {
    final prefs = await SharedPreferences.getInstance();
    _vibe = prefs.getString('vibe');
    final vibeMap = prefs.getStringList('vibeCounter') ?? [];
    _vibeCounter = {
      for (var e in vibeMap)
        e.split(':')[0]: int.parse(e.split(':')[1])
    };
    // --- Restore product state on reopen
    // _activeBudget is NOT restored anymore!
    // _activeCategory is NOT restored anymore!
    // _shownProductIds is NOT restored anymore!
  }

  Future<void> _saveMemory() async {
    final prefs = await SharedPreferences.getInstance();
    if (_vibe != null) prefs.setString('vibe', _vibe!);
    final vibeList = _vibeCounter.entries
        .map((e) => '${e.key}:${e.value}')
        .toList();
    prefs.setStringList('vibeCounter', vibeList);
    // --- Do NOT persist active product state anymore
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

    // 🔁 Reset product flow on fresh chat open (do not auto-assume category)
    _activeBudget = null;
    _activeCategory = null;
    _showProducts = false;
    _shownProductIds.clear();

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

  int? _parseBudgetFromText(String text) {
    final match = RegExp(r'(?:under|below|less than)?\s*(\d{2,6})').firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }


  String _prettyCategoryName(String raw) {
    switch (raw) {
      case 'boy_friend':
        return 'Boy Friend Gifts';
      case 'girl_friend':
        return 'Girl Friend Gifts';
      case 'bottles':
        return 'Bottles';
      case 'candle':
        return 'Candles';
      case 'letter':
        return 'Letters';
      case 'key_chain':
        return 'Keychains';
      case 'plusie':
        return 'Plush Toys';
      case 'caps':
        return 'Caps';
      case 'hair_accessories':
        return 'Hair Accessories';
      case 'ceramic':
        return 'Ceramics';
      case 'nails':
        return 'Nails';
      default:
        return raw;
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final lower = text.toLowerCase();
    final parsedBudget = _parseBudgetFromText(lower);

    final rawCategory =
        (lower.contains('bottle') ||
         lower.contains('cap') ||
         lower.contains('candle') ||
         lower.contains('letter') ||
         lower.contains('key') ||
         lower.contains('plush') ||
         lower.contains('hair') ||
         lower.contains('ceramic') ||
         lower.contains('nail'))
            ? _extractCategory(lower)
            : null;
    final detectedCategory =
        rawCategory != null ? _normalizeCategory(rawCategory) : null;
    final bool hasExplicitCategory =
        detectedCategory != null &&
        !lower.contains('gift') &&
        !lower.contains('gifts') &&
        !lower.contains('product') &&
        !lower.contains('products');

    final detectedVibe = _extractVibe(lower);
    if (detectedVibe != null) {
      setState(() {
        _vibe = detectedVibe;
        _vibeCounter[detectedVibe] = (_vibeCounter[detectedVibe] ?? 0) + 1;
      });
    }

    // ===== STRICT BUDGET FLOW =====
    if (parsedBudget != null) {
      setState(() {
        _messages.add(_ChatMessage.user(text));
      });
      _activeBudget = parsedBudget;
      _activeCategory = null;
      _showProducts = false;
      _shownProductIds.clear();

      final underBudget = products.where((p) => p.price <= parsedBudget).toList();

      if (underBudget.isEmpty) {
        setState(() {
          _messages.add(
            _ChatMessage.bot(
              "Sorry 💔 No products available under ₹$parsedBudget.",
            ),
          );
        });
        _scrollToBottom();
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
        return;
      }

      // CATEGORY SPECIFIED IN SAME MESSAGE
      if (hasExplicitCategory) {
        final catProducts = _virtualCategoryMap.containsKey(detectedCategory)
            ? underBudget.where((p) =>
                _virtualCategoryMap[detectedCategory]!
                    .contains(_normalizeCategory(_productCategory(p))))
                .toList()
            : underBudget.where((p) =>
                _normalizeCategory(_productCategory(p)) == detectedCategory)
                .toList();

        if (catProducts.isEmpty) {
          setState(() {
            _messages.add(
              _ChatMessage.bot(
                "Sorry 💔 There are no ${_prettyCategoryName(detectedCategory)} under ₹$parsedBudget.\nTry another category ✨",
              ),
            );
          });
          _scrollToBottom();
          if (mounted) {
            setState(() {
              _isTyping = false;
            });
          }
          return;
        }

        // Ensure no product cards shown here, only bot message
        setState(() {
          _messages.add(
            _ChatMessage.bot(
              "I found products under ₹$parsedBudget in ${_prettyCategoryName(detectedCategory)}! Want to see them? Type 'show me ${_prettyCategoryName(detectedCategory)}' or pick a category.",
            ),
          );
        });
        _scrollToBottom();
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
        return;
      }

      final categories = underBudget
          .map((p) => _normalizeCategory(_productCategory(p)))
          .toSet()
          .map(_prettyCategoryName)
          .join(', ');

      setState(() {
        _messages.add(
          _ChatMessage.bot(
            "I found products under ₹$parsedBudget 💗\nWhich category do you want?\n$categories",
          ),
        );
      });

      _scrollToBottom();
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
      return;
    }

    // ===== CATEGORY SELECTION / SWITCH AFTER BUDGET =====
    if (_activeBudget != null && hasExplicitCategory) {
      setState(() {
        _messages.add(_ChatMessage.user(text));
      });

      final catProducts = products.where((p) {
        if (p.price > _activeBudget!) return false;

        final normalized = _normalizeCategory(_productCategory(p));

        if (_virtualCategoryMap.containsKey(detectedCategory)) {
          return _virtualCategoryMap[detectedCategory]!.contains(normalized);
        }

        return normalized == _normalizeCategory(detectedCategory);
      }).toList();

      // ❌ No products in this category under budget
      if (catProducts.isEmpty) {
        setState(() {
          _messages.add(
            _ChatMessage.bot(
              "Sorry 💔 There are no ${_prettyCategoryName(detectedCategory)} under ₹$_activeBudget.\nTry another category ✨",
            ),
          );
        });
        _scrollToBottom();
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
        }
        return;
      }

      if (_activeCategory != detectedCategory) {
        _shownProductIds.clear();
      }

      // Availability check already above, so catProducts is not empty

      _activeCategory = detectedCategory;
      _showProducts = true;
      // 🔁 Learning-based AI: record user preference silently
      AiLearningService.recordCategory(_activeCategory!);
      AiLearningService.recordBudget(_activeBudget!);

      setState(() {
        final reasonText = _vibe != null
            ? "Based on your ${_vibe!} vibe ✨"
            : "Picked just for you 💗";

        _messages.add(
          _ChatMessage.bot(
            "✨ Showing best picks\n"
            "• Budget: ₹${_activeBudget}\n"
            "• Category: ${_prettyCategoryName(_activeCategory!)}\n"
            "$reasonText",
          ),
        );
        _messages.add(
          _ChatMessage.bot(
            "Want to see more ${_prettyCategoryName(_activeCategory!)} "
            "or try another category under ₹${_activeBudget}?",
          ),
        );
      });

      _scrollToBottom();
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
      return;
    }

    // "SHOW MORE" — SAME CATEGORY, NEW PRODUCTS ONLY
    if (lower.contains('show more') &&
        _activeBudget != null &&
        _activeCategory != null) {
      setState(() {
        _messages.add(_ChatMessage.user(text));
        _messages.add(
          _ChatMessage.bot("Here are more under ₹$_activeBudget 💗"),
        );
      });
      _scrollToBottom();
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
      return;
    }

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _isTyping = true;
    });
    // Persist any existing memory values (intent, budget, vibe)
    await _saveMemory();
    _saveChatHistory();
    _scrollToBottom();

    // PREVENT AI SERVICE FROM INTERRUPTING PRODUCT FLOW
    // if (_activeBudget != null) return;
    if (_activeBudget != null) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
      return;
    }

    String aiReply;
    try {
      aiReply = await AiService.sendMessage(text);
    } catch (e) {
      aiReply = "⚠️ I’m having trouble connecting right now. Please try again.";
    }
    if (mounted) {
      setState(() {
        _isTyping = false;
      });
    }

    setState(() {
      _messages.add(_ChatMessage.bot(aiReply));
    });

    _saveChatHistory();
    _scrollToBottom();
    // Safety fallback: ensure typing indicator is always cleared
    if (mounted) {
      setState(() {
        _isTyping = false;
      });
    }
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
    return WillPopScope(
      onWillPop: () async {
        // ✅ Preserve chat when user navigates back
        await _saveChatHistory();
        return true;
      },
      child: Scaffold(
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
            onPressed: () async {
              await SharedPreferences.getInstance()
                .then((prefs) => prefs.clear());

              if (!mounted) return;

              setState(() {
                _messages
                  ..clear()
                  ..add(
                    _ChatMessage.bot(
                      "Hey love ✨ I’m Sirelle-chan.\nReady to find something beautiful today?",
                    ),
                  );
                _activeBudget = null;
                _activeCategory = null;
                _showProducts = false;
                _shownProductIds.clear();
                _isTyping = false;
              });

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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_showProducts && _activeBudget != null && _activeCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ProductList(
                  budget: _activeBudget!,
                  category: _activeCategory,
                  vibe: _vibe,
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
    ),
    );
  }

  @override
  void dispose() {
    _saveChatHistory(); // ✅ Persist chat on exit
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
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
    // Access parent state for shownProductIds and _productCategory helper
    final state = context.findAncestorStateOfType<_SirelleChatPageState>();
    final _shownProductIds = state?._shownProductIds ?? <String>{};
    String Function(Product)? _productCategory;
    if (state != null) {
      _productCategory = state._productCategory;
    } else {
      _productCategory = (p) => 'unknown';
    }

    final available = products.where((p) {
      if (p.price > budget) return false;
      if (category != null && state != null) {
        final normalized = state._normalizeCategory(_productCategory!(p));

        // Handle virtual categories like boyfriend / girlfriend
        if (_SirelleChatPageState._virtualCategoryMap.containsKey(category)) {
          if (!_SirelleChatPageState._virtualCategoryMap[category]!
              .contains(normalized)) {
            return false;
          }
        } else {
          // Normal category comparison
          if (category != null && normalized != state._normalizeCategory(category!)) {
            return false;
          }
        }
      }
      if (_shownProductIds.contains(p.id)) return false;
      return true;
    }).toList()
      ..shuffle();

    if (available.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          "That's all I have under ₹$budget 💗",
          style: TextStyle(
            color: Colors.pink.shade400,
            fontSize: 13,
          ),
        ),
      );
    }

    final toShow = available.take(3).toList();
    for (final p in toShow) {
      _shownProductIds.add(p.id);
    }

    return Column(
      children: toShow
          .map((p) => _ProductChatCardDynamic(product: p))
          .toList(),
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