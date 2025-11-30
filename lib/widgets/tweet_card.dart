import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tweet_model.dart';
import '../providers/tweet_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/tweet_detail_screen.dart';
import 'user_avatar.dart';

class TweetCard extends StatelessWidget {
  final TweetModel tweet;

  const TweetCard({Key? key, required this.tweet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TweetDetailScreen(tweet: tweet),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(imageUrl: tweet.author.profileImage, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              tweet.author.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '@${tweet.author.username} · ${_formatTime(tweet.createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        iconSize: 20,
                        onPressed: () => _showOptionsMenu(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(tweet.content),

                  if (tweet.images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildImage(tweet.images.first),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        count: tweet.replies,
                        color: Colors.grey[600]!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TweetDetailScreen(tweet: tweet),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.repeat,
                        count: tweet.retweets,
                        color: tweet.isRetweeted
                            ? Colors.green
                            : Colors.grey[600]!,
                        onTap: () {
                          if (currentUser != null) {
                            try {
                              context.read<TweetProvider>().toggleRetweet(
                                tweet.id,
                                int.parse(currentUser.id),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal me-retweet: $e')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan login terlebih dahulu'),
                              ),
                            );
                          }
                        },
                      ),
                      _ActionButton(
                        icon: tweet.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        count: tweet.likes,
                        color: tweet.isLiked ? Colors.red : Colors.grey[600]!,
                        onTap: () {
                          if (currentUser != null) {
                            try {
                              final userId = int.parse(currentUser.id);
                              context.read<TweetProvider>().toggleLike(
                                tweet.id,
                                userId,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal menyukai: $e')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan login terlebih dahulu'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}h';
    if (diff.inHours > 0) return '${diff.inHours}j';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Baru saja';
  }

  Widget _buildImage(String imagePath) {

    if (imagePath.startsWith('/') ||
        imagePath.startsWith('file://') ||
        !imagePath.startsWith('http')) {
      return Image.file(
        File(imagePath.replaceAll('file://', '')),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image, size: 50)),
          );
        },
      );
    } else {

      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image, size: 50)),
          );
        },
      );
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Hapus'),
              onTap: () {
                Navigator.pop(context);
                context.read<TweetProvider>().deleteTweet(tweet.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_disabled_outlined),
              title: Text('Bisu @${tweet.author.username}'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: Text('Blokir @${tweet.author.username}'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;
  final bool showCount;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            if (showCount && count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(color: color, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
