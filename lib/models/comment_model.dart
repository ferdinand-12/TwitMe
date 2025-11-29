import 'user_model.dart';

class CommentModel {
  final String id;
  final String tweetId;
  final UserModel author;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.tweetId,
    required this.author,
    required this.content,
    required this.createdAt,
  });
}
