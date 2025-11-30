import 'user_model.dart';

enum NotificationType { like, retweet, reply, follow, mention }

class NotificationModel {
  final String id;
  final NotificationType type;
  final UserModel user;
  final String? tweetId;
  final String? content;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.user,
    this.tweetId,
    this.content,
    required this.createdAt,
    this.isRead = false,
  });

  String get message {
    switch (type) {
      case NotificationType.like:
        return 'menyukai tweet Anda';
      case NotificationType.retweet:
        return 'me-retweet tweet Anda';
      case NotificationType.reply:
        return 'membalas tweet Anda';
      case NotificationType.follow:
        return 'mengikuti Anda';
      case NotificationType.mention:
        return 'menyebut Anda di tweet';
    }
  }
}
