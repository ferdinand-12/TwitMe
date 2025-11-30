import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tweet_model.dart';
import '../providers/tweet_provider.dart';
import '../widgets/user_avatar.dart';

class TweetDetailScreen extends StatelessWidget {
  final TweetModel tweet;

  const TweetDetailScreen({Key? key, required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tweet'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  UserAvatar(imageUrl: tweet.author.profileImage, size: 48),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tweet.author.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (tweet.author.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 18,
                              color: Color(0xFF1DA1F2),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '@${tweet.author.username}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                tweet.content,
                style: const TextStyle(fontSize: 20, height: 1.4),
              ),
            ),
            if (tweet.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              Image.network(
                tweet.images.first,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _formatFullDate(tweet.createdAt),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _StatItem(count: tweet.retweets, label: 'Retweet'),
                  const SizedBox(width: 20),
                  _StatItem(count: tweet.likes, label: 'Suka'),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      tweet.isRetweeted ? Icons.repeat : Icons.repeat,
                      color: tweet.isRetweeted ? Colors.green : null,
                    ),
                    onPressed: () {
                      context.read<TweetProvider>().toggleRetweet(tweet.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      tweet.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: tweet.isLiked ? Colors.red : null,
                    ),
                    onPressed: () {
                      context.read<TweetProvider>().toggleLike(tweet.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      tweet.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: tweet.isBookmarked ? Colors.blue : null,
                    ),
                    onPressed: () {
                      context.read<TweetProvider>().toggleBookmark(tweet.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final day = date.day;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final month = months[date.month - 1];
    final year = date.year;
    return '$hour:$minute · $day $month $year';
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}