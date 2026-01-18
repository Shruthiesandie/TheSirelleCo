class UserProfile {
  // ======================
  // EXISTING PROFILE DATA
  // ======================
  String name;
  String birth;
  String height;
  String blood;
  String constellation;
  String avatarPath;

  // ======================
  // AI / BEHAVIORAL DATA
  // ======================
  int budgetUnder1500Count;
  int budgetAbove1500Count;

  int giftIntentCount;
  int selfIntentCount;

  int cuteVibeCount;
  int luxuryVibeCount;

  UserProfile({
    required this.name,
    required this.birth,
    required this.height,
    required this.blood,
    required this.constellation,
    required this.avatarPath,

    this.budgetUnder1500Count = 0,
    this.budgetAbove1500Count = 0,
    this.giftIntentCount = 0,
    this.selfIntentCount = 0,
    this.cuteVibeCount = 0,
    this.luxuryVibeCount = 0,
  });

  /// Default profile (safe fallback)
  factory UserProfile.initial() {
    return UserProfile(
      name: "Your Name",
      birth: "YYYY-MM-DD",
      height: "-- cm",
      blood: "--",
      constellation: "--",
      avatarPath: "assets/profile/default_avatar.png",
    );
  }

  // ======================
  // AI DERIVED PREFERENCES
  // ======================
  String get dominantBudget {
    return budgetUnder1500Count >= budgetAbove1500Count
        ? "under_1500"
        : "above_1500";
  }

  String get dominantIntent {
    return giftIntentCount >= selfIntentCount ? "gift" : "self";
  }

  String get dominantVibe {
    return cuteVibeCount >= luxuryVibeCount ? "cute" : "luxury";
  }

  /// Copy helper for edits (UI + AI safe)
  UserProfile copyWith({
    String? name,
    String? birth,
    String? height,
    String? blood,
    String? constellation,
    String? avatarPath,

    int? budgetUnder1500Count,
    int? budgetAbove1500Count,
    int? giftIntentCount,
    int? selfIntentCount,
    int? cuteVibeCount,
    int? luxuryVibeCount,
  }) {
    return UserProfile(
      name: name ?? this.name,
      birth: birth ?? this.birth,
      height: height ?? this.height,
      blood: blood ?? this.blood,
      constellation: constellation ?? this.constellation,
      avatarPath: avatarPath ?? this.avatarPath,

      budgetUnder1500Count:
          budgetUnder1500Count ?? this.budgetUnder1500Count,
      budgetAbove1500Count:
          budgetAbove1500Count ?? this.budgetAbove1500Count,
      giftIntentCount: giftIntentCount ?? this.giftIntentCount,
      selfIntentCount: selfIntentCount ?? this.selfIntentCount,
      cuteVibeCount: cuteVibeCount ?? this.cuteVibeCount,
      luxuryVibeCount: luxuryVibeCount ?? this.luxuryVibeCount,
    );
  }
}