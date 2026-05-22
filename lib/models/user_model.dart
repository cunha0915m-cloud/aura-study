/// Modelo de utilizador da Aura Study.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String bio;
  final int xp;
  final int level;
  final List<String> followers;
  final List<String> following;
  final List<String> favorites;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio = '',
    this.xp = 0,
    this.level = 1,
    this.followers = const [],
    this.following = const [],
    this.favorites = const [],
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      bio: map['bio'] ?? '',
      xp: (map['xp'] ?? 0) as int,
      level: (map['level'] ?? 1) as int,
      followers: List<String>.from(map['followers'] ?? const []),
      following: List<String>.from(map['following'] ?? const []),
      favorites: List<String>.from(map['favorites'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'bio': bio,
        'xp': xp,
        'level': level,
        'followers': followers,
        'following': following,
        'favorites': favorites,
      };
}
