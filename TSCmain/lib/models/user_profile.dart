

class UserProfile {
  String name;
  String birth;
  String height;
  String blood;
  String constellation;
  String avatarPath;

  UserProfile({
    required this.name,
    required this.birth,
    required this.height,
    required this.blood,
    required this.constellation,
    required this.avatarPath,
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

  /// Copy helper for edits
  UserProfile copyWith({
    String? name,
    String? birth,
    String? height,
    String? blood,
    String? constellation,
    String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      birth: birth ?? this.birth,
      height: height ?? this.height,
      blood: blood ?? this.blood,
      constellation: constellation ?? this.constellation,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}