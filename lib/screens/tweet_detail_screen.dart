import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tweet_model.dart';
import '../providers/tweet_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_avatar.dart';

class TweetDetailScreen extends StatefulWidget {
  final TweetModel tweet;

  const TweetDetailScreen({Key? key, required this.tweet}) : super(key: key);

  @override
  State<TweetDetailScreen> createState() => _TweetDetailScreenState();
}

class _TweetDetailScreenState extends State<TweetDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TweetProvider>().loadComments(widget.tweet.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    await context.read<TweetProvider>().addComment(
      widget.tweet.id,
      _commentController.text,
      user,
    );

    _commentController.clear();
    FocusScope.of(context).unfocus();
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
      'Des',
    ];
    final month = months[date.month - 1];
    final year = date.year;
    return '$hour:$minute · $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tweet')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        UserAvatar(
                          imageUrl: widget.tweet.author.profileImage,
                          size: 48,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.tweet.author.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (widget.tweet.author.isVerified) ...[
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
                              '@${widget.tweet.author.username}',
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
                      widget.tweet.content,
                      style: const TextStyle(fontSize: 20, height: 1.4),
                    ),
                  ),
                  if (widget.tweet.images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    widget.tweet.images.first.startsWith('http')
                        ? Image.network(
                            widget.tweet.images.first,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(widget.tweet.images.first),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _formatFullDate(widget.tweet.createdAt),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        _StatItem(
                          count: widget.tweet.retweets,
                          label: 'Retweet',
                        ),
                        const SizedBox(width: 20),
                        _StatItem(count: widget.tweet.likes, label: 'Suka'),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () {
                                // Focus on comment input
                                FocusScope.of(context).requestFocus();
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.repeat,
                                color: widget.tweet.isRetweeted
                                    ? Colors.green
                                    : null,
                              ),
                              onPressed: () {
                                final currentUser = authProvider.currentUser;
                                if (currentUser != null) {
                                  context.read<TweetProvider>().toggleRetweet(
                                    widget.tweet.id,
                                    int.parse(currentUser.id),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(),

                  // Comments Section
                  Consumer<TweetProvider>(
                    builder: (context, tweetProvider, _) {
                      final comments = tweetProvider.getComments(
                        widget.tweet.id,
                      );
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            leading: UserAvatar(
                              imageUrl: comment.author.profileImage,
                              size: 40,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  comment.author.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '@${comment.author.username}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.content),
                                const SizedBox(height: 4),
                                Text(
                                  _formatFullDate(comment.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Kirim balasan Anda',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1DA1F2)),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
