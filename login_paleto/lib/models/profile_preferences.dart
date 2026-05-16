class ProfilePreferences {
  final String displayName;
  final String motto;
  final String avatarKey;
  final String accentColorKey;
  final bool showEmailInProfile;

  const ProfilePreferences({
    required this.displayName,
    required this.motto,
    required this.avatarKey,
    required this.accentColorKey,
    required this.showEmailInProfile,
  });

  factory ProfilePreferences.defaults() {
    return const ProfilePreferences(
      displayName: 'Chef Paleto',
      motto: 'Cocinar, luchar, mejorar.',
      avatarKey: 'chef',
      accentColorKey: 'orange',
      showEmailInProfile: true,
    );
  }

  ProfilePreferences copyWith({
    String? displayName,
    String? motto,
    String? avatarKey,
    String? accentColorKey,
    bool? showEmailInProfile,
  }) {
    return ProfilePreferences(
      displayName: displayName ?? this.displayName,
      motto: motto ?? this.motto,
      avatarKey: avatarKey ?? this.avatarKey,
      accentColorKey: accentColorKey ?? this.accentColorKey,
      showEmailInProfile: showEmailInProfile ?? this.showEmailInProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'motto': motto,
      'avatarKey': avatarKey,
      'accentColorKey': accentColorKey,
      'showEmailInProfile': showEmailInProfile,
    };
  }

  factory ProfilePreferences.fromJson(Map<String, dynamic> json) {
    return ProfilePreferences(
      displayName: (json['displayName'] as String?)?.trim().isNotEmpty == true
          ? (json['displayName'] as String).trim()
          : 'Chef Paleto',
      motto: (json['motto'] as String?)?.trim().isNotEmpty == true
          ? (json['motto'] as String).trim()
          : 'Cocinar, luchar, mejorar.',
      avatarKey: (json['avatarKey'] as String?)?.trim().isNotEmpty == true
          ? (json['avatarKey'] as String).trim()
          : 'chef',
      accentColorKey:
          (json['accentColorKey'] as String?)?.trim().isNotEmpty == true
          ? (json['accentColorKey'] as String).trim()
          : 'orange',
      showEmailInProfile: json['showEmailInProfile'] as bool? ?? true,
    );
  }
}
