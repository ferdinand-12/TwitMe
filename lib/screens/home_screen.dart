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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final tweetProvider = context.read<TweetProvider>();
      final messageProvider = context.read<MessageProvider>();

      if (authProvider.currentUser != null) {
        final userId = int.parse(authProvider.currentUser!.id);
        tweetProvider.loadTweets();
        tweetProvider.loadLikedTweets(userId);
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
                      return CircleAvatar(
                        backgroundImage: NetworkImage(
                          authProvider.currentUser?.profileImage ??
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
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================================
        // TAB: Untuk Anda / Mengikuti
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
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == 0
                              ? const Color(0xFF1DA1F2)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      'Untuk Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _selectedTab == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedTab == 0 ? null : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == 1
                              ? const Color(0xFF1DA1F2)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      'Mengikuti',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _selectedTab == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedTab == 1 ? null : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                  await Future.delayed(const Duration(seconds: 1));
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
