class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String profileImage;
  final String coverImage;
  final int followers;
  final int following;
  final DateTime joinDate;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.profileImage = '',
    this.coverImage = '',
    this.followers = 0,
    this.following = 0,
    required this.joinDate,
    this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      bio: json['bio'] ?? '',
      profileImage: json['profileImage'] ?? '',
      coverImage: json['coverImage'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      joinDate: DateTime.parse(json['joinDate']),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'followers': followers,
      'following': following,
      'joinDate': joinDate.toIso8601String(),
      'isVerified': isVerified,
    };
  }
}
