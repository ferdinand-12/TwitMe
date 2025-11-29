import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/tweet_provider.dart';
import '../widgets/tweet_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _trending = [
    {
      'category': 'Teknologi · Trending',
      'title': '#FlutterDev',
      'tweets': '25.4K Tweets',
    },
    {
      'category': 'Politik · Trending',
      'title': 'Pemilu 2024',
      'tweets': '105K Tweets',
    },
    {
      'category': 'Olahraga · Trending',
      'title': 'Liga Champions',
      'tweets': '87.3K Tweets',
    },
    {
      'category': 'Hiburan · Trending',
      'title': '#MovieNight',
      'tweets': '45.8K Tweets',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final tweetProvider = context.watch<TweetProvider>();
    final searchQuery = searchProvider.searchQuery;

    // Get search results
    final tweetResults = searchProvider.searchTweets(tweetProvider.tweets);
    final hasResults = searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari TwitMe',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      searchProvider.clearSearch();
                    },
                  )
                : null,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onChanged: (value) {
            searchProvider.updateSearchQuery(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: hasResults
          ? _buildSearchResults(tweetResults)
          : _buildTrendingTopics(),
    );
  }

  Widget _buildSearchResults(List tweetResults) {
    if (tweetResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil ditemukan',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tweetResults.length,
      itemBuilder: (context, index) {
        return TweetCard(tweet: tweetResults[index]);
      },
    );
  }

  Widget _buildTrendingTopics() {
    return ListView.builder(
      itemCount: _trending.length,
      itemBuilder: (context, index) {
        final item = _trending[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            item['category'],
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['tweets'],
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          onTap: () {
            print('Tapped trending: ${item['title']}');
            _searchController.text = item['title'];
            context.read<SearchProvider>().updateSearchQuery(item['title']);
            // Force focus removal to hide keyboard if open
            FocusScope.of(context).unfocus();
          },
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        );
      },
    );
  }
}
