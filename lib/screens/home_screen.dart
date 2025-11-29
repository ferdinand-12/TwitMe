import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tweet_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../widgets/tweet_card.dart';
import 'search_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'compose_tweet_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _FeedScreen(),
    const SearchScreen(),
    const MessagesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final tweetProvider = context.read<TweetProvider>();
      final messageProvider = context.read<MessageProvider>();

      if (authProvider.currentUser != null) {
        final userId = int.parse(authProvider.currentUser!.id);
        // Load liked tweets first (this will load retweets and then all tweets)
        await tweetProvider.loadLikedTweets(userId);
        messageProvider.loadConversations(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final profileImage =
                          authProvider.currentUser?.profileImage ?? '';
                      return CircleAvatar(
                        backgroundImage: profileImage.isNotEmpty
                            ? (profileImage.startsWith('http')
                                  ? NetworkImage(profileImage) as ImageProvider
                                  : FileImage(File(profileImage)))
                            : const NetworkImage(
                                'https://i.pravatar.cc/150?img=1',
                              ),
                      );
                    },
                  ),
                ),
              ),

              // ================================
              // LOGO DIGANTI MENGGUNAKAN ASSET
              // ================================
              title: Image.asset('assets/icon/app_icon.png', height: 32),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,

      // ================================
      // BODY
      // ================================
      body: _screens[_selectedIndex],

      // ================================
      // BOTTOM NAVIGATION BAR
      // ================================
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 224, 238, 255),
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color.fromARGB(255, 112, 112, 112),
        unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),

        showSelectedLabels: false,
        showUnselectedLabels: false,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Pesan',
          ),
        ],
      ),

      // ================================
      // FAB (Tombol Tweet)
      // ================================
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComposeTweetScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF1DA1F2),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _FeedScreen extends StatefulWidget {
  const _FeedScreen();

  @override
  State<_FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<_FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================================
        // HEADER: Untuk Anda
        // ================================
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]!
                    : Colors.grey[200]!,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF1DA1F2), width: 3),
              ),
            ),
            child: const Text(
              'Untuk Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // ================================
        // LIST TWEETS
        // ================================
        Expanded(
          child: Consumer<TweetProvider>(
            builder: (context, tweetProvider, _) {
              return RefreshIndicator(
                onRefresh: () async {
                  await tweetProvider.loadTweets();
                },
                child: ListView.builder(
                  itemCount: tweetProvider.tweets.length,
                  itemBuilder: (context, index) {
                    return TweetCard(tweet: tweetProvider.tweets[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
