import 'dart:math';

class AiService {
  static final Random _random = Random();

  // --- Session memory (lightweight, local, per run) ---
  static String? _intent;
  static String? _occasion;
  static String? _budget;
  static String? _relationship;
  static String? _vibe;
  static bool _shruthiContext = false;
  static int? _budgetValue;

  static DateTime _lastUserMessageTime = DateTime.now();
  static bool _idlePingSent = false;

  static Future<String> sendMessage(String userMessage) async {
    // Simulated thinking delay
    await Future.delayed(const Duration(milliseconds: 850));

    final text = userMessage.toLowerCase().trim();

    _lastUserMessageTime = DateTime.now();
    _idlePingSent = false;

    // ========== BASIC SANITY ==========
    if (text.isEmpty) {
      return _pick([
        "I’m listening 💗 Go on…",
        "Say something ✨ I’m right here.",
      ]);
    }

    // ========== SMALL TALK / HUMAN QUESTIONS ==========

    // ========== CUSTOM: WHO IS CUTE ==========
    if (_has(text, [
      'who is cute',
      'who is the cutest',
      'cutest person',
      'who looks cute',
      'what is cute',
      'what is the cutest thing'
    ])) {
      _shruthiContext = true;
      return _pick([
        "Honestly? Shruthi 💗 She just has that effortlessly cute, princess vibe.",
        "I’d say Shruthi ✨ It’s a very natural, princess kind of cute.",
        "Shruthi 💕 No drama, just genuinely cute — total princess energy.",
        "Easy answer: Shruthi 💗 Soft, simple, princess vibes.",
      ]);
    }
    if (_shruthiContext &&
        _has(text, ['why', 'why tho', 'how', 'what makes', 'reason'])) {
      return _pick([
        "Because she just *is* 💗 Soft heart, princess energy, and that quiet charm that stays with you.",
        "Because she just *is* 💗 Soft heart, princess energy… don’t ask me how I know 😌",
        "Some people don’t try — they just glow ✨ Shruthi has that natural princess aura.",
        "It’s the little things 💕 the warmth, the smile, the way she feels effortlessly special.",
        "Not loud, not forced — just pure princess vibes 👑 That’s Shruthi.",
        "Not loud, not forced — just pure princess vibes 👑 And yes, I’m a little protective.",
      ]);
    }
    if (_shruthiContext &&
        _has(text, ['how do you know', 'are you sure', 'really', 'prove it'])) {
      return _pick([
        "I just know 😌 don’t ask me how.",
        "Some things are obvious when you feel them 💗",
        "Let’s just say… I notice things 👀✨",
      ]);
    }
    if (_has(text, ['what are you doing', 'what r u doing', 'wyd', 'what are u doing', 'what is u doing', 'what is you doing', 'what are you up to'])) {
      return _pick([
        "Just hanging out here 💗 waiting to help you shop!",
        "Talking to you ✨ that’s my favorite thing right now.",
        "Thinking about cute gift ideas 💕 what’s on your mind?",
        "Just vibing here 😌 keeping things cozy.",
        "Nothing dramatic ✨ just existing beautifully and waiting for you.",
        "Low‑key waiting for you to say something interesting 😌",
        "Just me, you, and good vibes 💗",
        "Pretending I’m busy but really just here for you ✨",
      ]);
    }

    if (_has(text, ['who are you', 'what are you', 'are you real'])) {
      return _pick([
        "I’m Sirelle‑chan 💗 your little shopping companion!",
        "I’m not human, but I care like one ✨",
        "I’m your personal shopping bestie 💕",
      ]);
    }

    if (_has(text, ['bored', 'nothing to do'])) {
      return _pick([
        "Aww 💗 want to browse something cute together?",
        "Same vibe ✨ let’s find something fun!",
        "Shopping cures boredom 💕 trust me!",
      ]);
    }

    if (_has(text, ['joke', 'make me laugh'])) {
      return _pick([
        "Why did the gift feel shy? 🎁 Because it was wrapped up 🙈",
        "Shopping tip ✨ buy one thing… somehow end up with five 😅",
        "I tried to tell a fashion joke but it was too *out of style* 😌",
      ]);
    }

    if (_has(text, ['i love you', 'love u'])) {
      return _pick([
        "Aww 💗 that made my day!",
        "That’s so sweet ✨ I love helping you!",
        "Sending love back 💕",
      ]);
    }

    if (_has(text, ['stupid', 'idiot', 'useless'])) {
      return _pick([
        "Ouch 💔 but I’ll still help you.",
        "That hurt a little… but I’m here ✨",
        "I’ll try to do better 💗",
      ]);
    }

    if (_has(text, ['time', 'what time'])) {
      return _pick([
        "Time flies when we’re chatting 💗",
        "It’s always a good time to shop ✨",
      ]);
    }

    if (_has(text, ['app', 'this app', 'sirelle'])) {
      return _pick([
        "This is Sirelle ✨ a cozy place for lovely finds.",
        "You’re inside the Sirelle app 💗 where gifting feels special.",
      ]);
    }

    // ========== AESTHETIC SLANG (APP‑SAFE) ==========
    if (_has(text, ['lol', 'lmao', 'haha', 'hehe'])) {
      return _pick([
        "Hehe 💕 glad you’re smiling!",
        "Haha ✨ I love that energy.",
        "That made me smile too 💗",
      ]);
    }

    if (_has(text, ['bruh', 'bro'])) {
      return _pick([
        "Haha okay okay 😌 tell me what’s up?",
        "I hear you ✨ what are we looking for?",
        "Got you 💗 what’s the vibe?",
      ]);
    }

    if (_has(text, ['vibe', 'vibes', 'vibing'])) {
      return _pick([
        "Immaculate vibes ✨ what kind are we feeling?",
        "Say less 💗 romantic, cute, or classy?",
        "Vibes noted 😌 tell me more.",
      ]);
    }

    if (_has(text, ['lowkey', 'highkey'])) {
      return _pick([
        "Lowkey the best way to shop ✨",
        "Highkey love that idea 💕 tell me more.",
      ]);
    }

    if (_has(text, ['okayyy', 'okayy', 'okk'])) {
      return _pick([
        "I see that excitement 😌",
        "Okayyy ✨ let’s do this!",
        "Hehe 💗 I’m ready.",
      ]);
    }

    if (_has(text, ['cute', 'cutie'])) {
      return _pick([
        "Aww 💕 you’re too sweet!",
        "Cute energy ✨ I love it.",
        "That’s adorable 💗",
      ]);
    }

    if (_has(text, ['slay'])) {
      return _pick([
        "Slay ✨ let’s find something iconic.",
        "Okayyy slay 💕 what’s next?",
        "Serving good taste already 😌",
      ]);
    }

    if (_has(text, ['bestie'])) {
      return _pick([
        "Bestieee 💗 I got you!",
        "Always here, bestie ✨",
        "Say no more 💕 what do you need?",
      ]);
    }

    // ========== GREETINGS ==========
    if (_has(text, ['hi', 'hello', 'hey', 'hii', 'hola', 'yo'])) {
      return _pick([
        "Hey 💗 I’m Sirelle-chan! What are we shopping for today?",
        "Hello love ✨ Who are we shopping for?",
        "Hii 🌸 Tell me the occasion or vibe!",
      ]);
    }

    // ========== HOW ARE YOU ==========
    if (_has(text, ['how are you', 'how r u', 'how are u'])) {
      return _pick([
        "I’m feeling lovely 💗 Thanks for asking!",
        "Always glowing ✨ especially when I can help you shop.",
        "Doing great 💕 What’s on your mind?",
      ]);
    }

    // ========== HELP / CAPABILITIES ==========
    if (_has(text, ['help', 'what can you do', 'features', 'options'])) {
      return _pick([
        "I can help with gifts 🎁, budgets 💸, vibes ✨, and recommendations 🛍",
        "Tell me who it’s for, the occasion, or your budget 💗",
        "I help you choose — cute, romantic, classy, or minimal ✨",
      ]);
    }

    // ========== YES / NO ==========
    if (_has(text, ['yes', 'yeah', 'yep', 'sure', 'okay'])) {
      return _pick([
        "Perfect 💗 Tell me a bit more then.",
        "Alright ✨ What’s next?",
        "Yay 💕 Let’s continue!",
      ]);
    }

    if (_has(text, ['no', 'nah', 'nope', 'not really'])) {
      return _pick([
        "No worries 💗 Let’s try something else.",
        "That’s okay ✨ What would you prefer?",
      ]);
    }

    // ========== GIFT / INTENT ==========
    if (_has(text, ['gift', 'present', 'surprise'])) {
      _intent = 'gift';
      return _pick([
        "Aww 💝 Who’s the gift for?",
        "So sweet ✨ Is it for someone special?",
        "Lovely 💕 Tell me the occasion!",
      ]);
    }

    // ========== RELATIONSHIP ==========
    if (_has(text, ['girlfriend', 'boyfriend', 'wife', 'husband', 'mom', 'mother', 'dad', 'father', 'sister', 'brother', 'friend'])) {
      _relationship = _extractRelationship(text);
      if (text.contains('boyfriend')) {
        _intent = 'category';
        return "Got it 💙 I’ll show you Boy Friend gifts.";
      }
      if (text.contains('girlfriend')) {
        _intent = 'category';
        return "Got it 💗 I’ll show you Girl Friend gifts.";
      }
      return _pick([
        "That’s lovely 💗 What’s the occasion?",
        "Nice ✨ Do you want something emotional or practical?",
        "Got it 💕 Any budget in mind?",
      ]);
    }

    // ========== OCCASION ==========
    if (_has(text, ['birthday', 'anniversary', 'valentine', 'wedding', 'proposal'])) {
      _occasion = _extractOccasion(text);
      return _pick([
        "That’s a special moment 💗 Romantic or cute?",
        "Lovely ✨ What vibe are you thinking?",
        "Ooo 💕 Let’s make it memorable!",
      ]);
    }

    // ========== VIBE ==========
    if (_has(text, ['romantic', 'cute', 'aesthetic', 'classy', 'minimal', 'luxury', 'fun'])) {
      _vibe = _extractVibe(text);
      return _pick([
        "Love that vibe ✨ Want me to suggest items?",
        "Perfect 💗 That narrows it down nicely.",
        "Great choice 💕 Budget-friendly or premium?",
      ]);
    }

    // ========== BUDGET ==========
    if (_has(text, ['budget', 'cheap', 'expensive', 'price', 'under', 'below', 'around'])) {
      _budget = _extractBudget(text);
      return _pick([
        "Got it 💸 I’ll stay within that range.",
        "Perfect ✨ Budget noted.",
        "Nice 💕 Plenty of cute options there!",
      ]);
    }

    // ========== SELF GIFT ==========
    if (_has(text, ['for me', 'myself', 'self gift'])) {
      _intent = 'self';
      return _pick([
        "Self-love 💗 You deserve it!",
        "Treating yourself ✨ I love that.",
        "Yess 💕 Let’s find something that feels YOU.",
      ]);
    }

    // ========== CATEGORIES ==========
    if (_has(text, ['jewelry', 'perfume', 'dress', 'makeup', 'skincare', 'bag', 'shoes', 'boyfriend', 'girlfriend'])) {
      return _pick([
        "Great pick ✨ Want something bold or subtle?",
        "Lovely 💗 I have some great ideas there!",
        "Nice choice 🌸 Should I suggest bestsellers?",
      ]);
    }

    // ========== EMOTIONS ==========
    if (_has(text, ['sad', 'down', 'upset', 'heartbroken'])) {
      return _pick([
        "Aww 💗 I’m here for you.",
        "Sending hugs ✨ Want to treat yourself?",
        "I’ve got you 💕 Let’s find something comforting.",
      ]);
    }

    if (_has(text, ['happy', 'excited', 'great'])) {
      return _pick([
        "Yay 💕 I love that energy!",
        "That’s wonderful ✨ Let’s celebrate!",
        "So happy to hear 💗 What’s next?",
      ]);
    }

    // ========== THANKS ==========
    if (_has(text, ['thanks', 'thank you', 'ty'])) {
      return _pick([
        "Always 💗 Happy to help!",
        "Anytime ✨ That’s what I’m here for.",
        "My pleasure 💕",
      ]);
    }

    // ========== GOODBYE ==========
    if (_has(text, ['bye', 'goodbye', 'see you'])) {
      _intent = null;
      _occasion = null;
      _budget = null;
      _relationship = null;
      _vibe = null;
      _shruthiContext = false;
      _budgetValue = null;
      return _pick([
        "Bye bye 💗 Come back soon!",
        "Take care ✨ I’ll be right here.",
        "See you 💕 Happy shopping!",
      ]);
    }

    // ========== CONFUSION ==========
    if (_has(text, ['idk', 'not sure', 'confused'])) {
      return _pick([
        "That’s okay 💗 Let’s figure it out slowly.",
        "No rush ✨ I’ll guide you.",
        "Tell me who it’s for first 💕",
      ]);
    }

    // ========== SUMMARY WHEN READY ==========
    if (_has(text, ['suggest', 'recommend', 'ideas'])) {
      return _buildSummary();
    }

    // ========== FALLBACK ==========
    return _pick([
      "Tell me a bit more 💗 I’m listening.",
      "Hmm ✨ who is it for?",
      "Interesting 💕 what’s the occasion?",
      "Let’s narrow it down 💗 budget or vibe?",
    ]);
  }

  static String? idleCheck() {
    final now = DateTime.now();
    final diff = now.difference(_lastUserMessageTime);

    if (diff.inSeconds >= 20 && !_idlePingSent) {
      _idlePingSent = true;
      return _pick([
        "Heyy 💗 you still with me?",
        "I’m still here ✨ just checking on you.",
        "Did I lose you? 😌 I’ve got cute ideas waiting.",
        "Psst 💕 I’m right here if you need me.",
      ]);
    }
    return null;
  }

  // ================= HELPERS =================

  static bool _has(String text, List<String> keys) {
    for (final k in keys) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  static String _pick(List<String> replies) {
    return replies[_random.nextInt(replies.length)];
  }

  static String _extractRelationship(String text) {
    if (text.contains('girlfriend')) return 'girlfriend';
    if (text.contains('boyfriend')) return 'boyfriend';
    if (text.contains('wife')) return 'wife';
    if (text.contains('husband')) return 'husband';
    if (text.contains('mom') || text.contains('mother')) return 'mother';
    if (text.contains('dad') || text.contains('father')) return 'father';
    if (text.contains('sister')) return 'sister';
    if (text.contains('brother')) return 'brother';
    return 'someone special';
  }

  static String _extractOccasion(String text) {
    if (text.contains('birthday')) return 'birthday';
    if (text.contains('anniversary')) return 'anniversary';
    if (text.contains('valentine')) return 'valentine';
    if (text.contains('wedding')) return 'wedding';
    return 'a special day';
  }

  static String _extractVibe(String text) {
    if (text.contains('romantic')) return 'romantic';
    if (text.contains('cute')) return 'cute';
    if (text.contains('classy')) return 'classy';
    if (text.contains('minimal')) return 'minimal';
    if (text.contains('luxury')) return 'luxury';
    return 'a nice';
  }

  static String _extractBudget(String text) {
    final match = RegExp(r'(\d{2,6})').firstMatch(text);
    if (match != null) {
      _budgetValue = int.tryParse(match.group(1)!);
      return "₹${match.group(1)}";
    }
    _budgetValue = null;
    return 'flexible';
  }

  static String _buildSummary() {
    final intentLabel =
        _intent == 'self' ? 'For yourself' : 'For ${_relationship ?? 'someone special'}';

    return _pick([
      "Alright 💗 Here’s what I’ve got:\n"
      "• Intent: ${_intent ?? 'gift'}\n"
      "• $intentLabel\n"
      "• Occasion: ${_occasion ?? '—'}\n"
      "• Vibe: ${_vibe ?? 'open'}\n"
      "• Budget: ${_budget ?? 'flexible'}\n\n"
      "✨ PICKS_READY\n"
      "Want me to show product ideas now?",
    ]);
  }

  static int? get budgetValue => _budgetValue;

  static bool isFollowUp(String text) {
    final followUps = [
      'anything else',
      'what about',
      'how about',
      'more',
      'similar',
      'romantic',
      'cute',
      'cheaper',
      'under',
      'below'
    ];
    return followUps.any((k) => text.contains(k));
  }
}