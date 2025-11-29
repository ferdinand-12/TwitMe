import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/tweet_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/tweet_card.dart';
import '../widgets/custom_button.dart';
import 'edit_profile_screen.dart';
import '../models/comment_model.dart';
import '../models/tweet_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final tweets = context.watch<TweetProvider>().tweets;
    final userTweets = tweets.where((t) => t.author.id == user?.id).toList();

    if (user != null && _selectedTab == 1) {
      context.read<TweetProvider>().loadUserReplies(int.parse(user.id));
      context.read<TweetProvider>().loadRetweetedTweets(int.parse(user.id));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (user?.coverImage.isNotEmpty ?? false)
                    Image.network(user!.coverImage, fit: BoxFit.cover)
                  else
                    Container(color: Colors.grey[300]),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showProfileMenu(context),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              user?.profileImage.isNotEmpty ?? false
                              ? NetworkImage(user!.profileImage)
                              : null,
                          child: user?.profileImage.isEmpty ?? true
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: CustomButton(
                          text: 'Edit Profil',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                          isOutlined: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        user?.displayName ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.isVerified ?? false) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 20,
                          color: Color(0xFF1DA1F2),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user?.username ?? ''}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                  if (user?.bio.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Text(user!.bio),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Bergabung ${_formatDate(user?.joinDate ?? DateTime.now())}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${user?.following ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mengikuti',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '${user?.followers ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pengikut',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!
                        : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildTab('Tweet', 0),
                  _buildTab('Balasan', 1),
                  _buildTab('Media', 2),
                  _buildTab('Suka', 3),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_selectedTab == 0) {
                  return TweetCard(tweet: userTweets[index]);
                } else if (_selectedTab == 1) {
                  final provider = context.watch<TweetProvider>();
                  final replies = provider.userReplies;
                  final retweets = provider.userRetweets;

                  final combined = [
                    ...replies.map(
                      (r) => {'type': 'reply', 'data': r, 'date': r.createdAt},
                    ),
                    ...retweets.map(
                      (r) => {
                        'type': 'retweet',
                        'data': r,
                        'date': r.createdAt,
                      },
                    ),
                  ];
                  combined.sort(
                    (a, b) => (b['date'] as DateTime).compareTo(
                      a['date'] as DateTime,
                    ),
                  );

                  if (index < combined.length) {
                    final item = combined[index];
                    if (item['type'] == 'reply') {
                      final reply = item['data'] as CommentModel;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            reply.author.profileImage,
                          ),
                        ),
                        title: Text(
                          reply.author.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${reply.author.username}'),
                            const SizedBox(height: 4),
                            Text(reply.content),
                          ],
                        ),
                        trailing: Text(
                          '${reply.createdAt.day}/${reply.createdAt.month}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    } else {
                      final tweet = item['data'] as TweetModel;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 48, top: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.repeat,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${user?.displayName} me-retweet',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TweetCard(tweet: tweet),
                        ],
                      );
                    }
                  }
                } else if (_selectedTab == 2) {
                  final mediaTweets = userTweets
                      .where((t) => t.images.isNotEmpty)
                      .toList();
                  if (index < mediaTweets.length) {
                    return TweetCard(tweet: mediaTweets[index]);
                  }
                } else if (_selectedTab == 3) {
                  final likedTweets = context
                      .watch<TweetProvider>()
                      .likedTweets;
                  if (index < likedTweets.length) {
                    return TweetCard(tweet: likedTweets[index]);
                  }
                }
                return const SizedBox();
              },
              childCount: _selectedTab == 0
                  ? userTweets.length
                  : (_selectedTab == 1
                        ? (context.watch<TweetProvider>().userReplies.length +
                              context
                                  .watch<TweetProvider>()
                                  .userRetweets
                                  .length)
                        : (_selectedTab == 2
                              ? userTweets
                                    .where((t) => t.images.isNotEmpty)
                                    .length
                              : (_selectedTab == 3
                                    ? context
                                          .watch<TweetProvider>()
                                          .likedTweets
                                          .length
                                    : 0))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF1DA1F2)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? null : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                context.read<ThemeProvider>().isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              title: Text(
                context.read<ThemeProvider>().isDarkMode
                    ? 'Mode Terang'
                    : 'Mode Gelap',
              ),
              onTap: () {
                context.read<ThemeProvider>().toggleTheme();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
