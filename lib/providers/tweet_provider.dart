import 'package:flutter/material.dart';
import '../models/tweet_model.dart';
import '../models/user_model.dart';

class TweetProvider with ChangeNotifier {
  final List<TweetModel> _tweets = [];
  final List<TweetModel> _bookmarks = [];

  List<TweetModel> get tweets => _tweets;
  List<TweetModel> get bookmarks => _bookmarks;

  TweetProvider() {
    _loadMockTweets();
  }

  void _loadMockTweets() {
    final mockUsers = [
      UserModel(
        id: '1',
        username: 'johndoe',
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/150?img=12',
        isVerified: true,
        joinDate: DateTime(2019, 1, 1),
      ),
      UserModel(
        id: '2',
        username: 'janesmth',
        displayName: 'Jane Smith',
        profileImage: 'https://i.pravatar.cc/150?img=45',
        joinDate: DateTime(2020, 6, 15),
      ),
      UserModel(
        id: '3',
        username: 'techguru',
        displayName: 'Tech Guru',
        profileImage: 'https://i.pravatar.cc/150?img=33',
        isVerified: true,
        joinDate: DateTime(2018, 3, 20),
      ),
    ];

    _tweets.addAll([
      TweetModel(
        id: '1',
        author: mockUsers[0],
        content: 'Excited to share my latest Flutter project! 🚀 Check it out and let me know what you think. #FlutterDev #MobileDev',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 245,
        retweets: 48,
        replies: 23,
      ),
      TweetModel(
        id: '2',
        author: mockUsers[1],
        content: 'Just finished reading an amazing book on software architecture. Highly recommended for all developers! 📚',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 189,
        retweets: 32,
        replies: 15,
      ),
      TweetModel(
        id: '3',
        author: mockUsers[2],
        content: 'The future of AI is incredible. Can\'t wait to see what 2025 brings! 🤖✨',
        images: ['https://picsum.photos/600/400?random=1'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likes: 1523,
        retweets: 342,
        replies: 156,
      ),
      TweetModel(
        id: '4',
        author: mockUsers[0],
        content: 'Coffee + Code = Perfect morning ☕️💻',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 567,
        retweets: 89,
        replies: 45,
      ),
    ]);
  }

  void addTweet(String content, List<String> images) {
    final newTweet = TweetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: UserModel(
        id: '1',
        username: 'user123',
        displayName: 'User Name',
        profileImage: 'https://i.pravatar.cc/150?img=1',
        isVerified: true,
        joinDate: DateTime.now(),
      ),
      content: content,
      images: images,
      createdAt: DateTime.now(),
    );
    _tweets.insert(0, newTweet);
    notifyListeners();
  }

  void toggleLike(String tweetId) {
    final index = _tweets.indexWhere((t) => t.id == tweetId);
    if (index != -1) {
      _tweets[index].isLiked = !_tweets[index].isLiked;
      _tweets[index].likes += _tweets[index].isLiked ? 1 : -1;
      notifyListeners();
    }
  }

  void toggleRetweet(String tweetId) {
    final index = _tweets.indexWhere((t) => t.id == tweetId);
    if (index != -1) {
      _tweets[index].isRetweeted = !_tweets[index].isRetweeted;
      _tweets[index].retweets += _tweets[index].isRetweeted ? 1 : -1;
      notifyListeners();
    }
  }

  void toggleBookmark(String tweetId) {
    final index = _tweets.indexWhere((t) => t.id == tweetId);
    if (index != -1) {
      _tweets[index].isBookmarked = !_tweets[index].isBookmarked;
      if (_tweets[index].isBookmarked) {
        _bookmarks.add(_tweets[index]);
      } else {
        _bookmarks.removeWhere((t) => t.id == tweetId);
      }
      notifyListeners();
    }
  }

  void deleteTweet(String tweetId) {
    _tweets.removeWhere((t) => t.id == tweetId);
    notifyListeners();
  }
}