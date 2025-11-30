import 'user_model.dart';

class TweetModel {
  final String id;
  final UserModel author;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  int likes;
  int retweets;
  int replies;
  bool isLiked;
  bool isRetweeted;
  bool isBookmarked;
  final String? replyToId;
  final String? quoteTweetId;

  TweetModel({
    required this.id,
    required this.author,
    required this.content,
    this.images = const [],
    required this.createdAt,
    this.likes = 0,
    this.retweets = 0,
    this.replies = 0,
    this.isLiked = false,
    this.isRetweeted = false,
    this.isBookmarked = false,
    this.replyToId,
    this.quoteTweetId,
  });

  factory TweetModel.fromJson(Map<String, dynamic> json) {
    return TweetModel(
      id: json['id'],
      author: UserModel.fromJson(json['author']),
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
      retweets: json['retweets'] ?? 0,
      replies: json['replies'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isRetweeted: json['isRetweeted'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      replyToId: json['replyToId'],
      quoteTweetId: json['quoteTweetId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'content': content,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'retweets': retweets,
      'replies': replies,
      'isLiked': isLiked,
      'isRetweeted': isRetweeted,
      'isBookmarked': isBookmarked,
      'replyToId': replyToId,
      'quoteTweetId': quoteTweetId,
    };
  }
}
