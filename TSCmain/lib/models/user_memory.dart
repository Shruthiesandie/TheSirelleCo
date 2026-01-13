class UserMemory {
  // Core intent memory
  String? intent;        // gift / self
  String? relationship; // girlfriend, mom, friend, etc.
  String? occasion;     // birthday, anniversary, etc.
  String? vibe;         // romantic, cute, classy, luxury
  String? budget;       // under 2000, 5k, flexible

  // Conversation flow
  String stage;          // greeting, intent, relationship, occasion, budget, suggest

  UserMemory({
    this.intent,
    this.relationship,
    this.occasion,
    this.vibe,
    this.budget,
    this.stage = 'greeting',
  });

  /// Convert memory to a readable summary (used by AI + UI)
  String summary() {
    final lines = <String>[];

    if (intent != null) lines.add("Intent: $intent");
    if (relationship != null) lines.add("For: $relationship");
    if (occasion != null) lines.add("Occasion: $occasion");
    if (vibe != null) lines.add("Vibe: $vibe");
    if (budget != null) lines.add("Budget: $budget");

    if (lines.isEmpty) {
      return "No preferences set yet.";
    }

    return lines.join(" • ");
  }

  /// Serialize for SharedPreferences
  Map<String, String> toMap() {
    final Map<String, String> data = {};

    if (intent != null) data['intent'] = intent!;
    if (relationship != null) data['relationship'] = relationship!;
    if (occasion != null) data['occasion'] = occasion!;
    if (vibe != null) data['vibe'] = vibe!;
    if (budget != null) data['budget'] = budget!;
    data['stage'] = stage;

    return data;
  }

  /// Restore from SharedPreferences
  factory UserMemory.fromMap(Map<String, String> map) {
    return UserMemory(
      intent: map['intent'],
      relationship: map['relationship'],
      occasion: map['occasion'],
      vibe: map['vibe'],
      budget: map['budget'],
      stage: map['stage'] ?? 'greeting',
    );
  }

  /// Reset memory (used when chat is cleared)
  void reset() {
    intent = null;
    relationship = null;
    occasion = null;
    vibe = null;
    budget = null;
    stage = 'greeting';
  }
}
