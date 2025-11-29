import 'package:flutter/material.dart';
import '../models/tweet_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';
import '../helpers/database_helper.dart';

class TweetProvider with ChangeNotifier {
  List<TweetModel> _tweets = [];
  List<String> _likedTweetIds = [];
  List<String> _retweetedTweetIds = [];
  List<TweetModel> _userRetweets = [];
  int? _currentUserId;

  List<TweetModel> get tweets => _tweets;
  List<TweetModel> get likedTweets =>
      _tweets.where((t) => _likedTweetIds.contains(t.id)).toList();
  List<TweetModel> get userRetweets => _userRetweets;

  Map<String, List<CommentModel>> _comments = {};
  List<CommentModel> _userReplies = [];

  List<CommentModel> getComments(String tweetId) {
    return _comments[tweetId] ?? [];
  }

  List<CommentModel> get userReplies => _userReplies;

  Future<void> loadComments(String tweetId) async {
    try {
      final db = DatabaseHelper.instance;
      final commentsData = await db.getCommentsByTweetId(int.parse(tweetId));

      _comments[tweetId] = commentsData.map((data) {
        return CommentModel(
          id: data['id'].toString(),
          tweetId: data['tweetId'].toString(),
          author: UserModel(
            id: data['userId'].toString(),
            username: data['username'],
            displayName: data['displayName'],
            profileImage: data['profileImage'] ?? '',
            isVerified: data['isVerified'] == 1,
            joinDate: DateTime.now(),
          ),
          content: data['content'],
          createdAt: DateTime.parse(data['createdAt']),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<void> loadUserReplies(int userId) async {
    try {
      final db = DatabaseHelper.instance;
      final repliesData = await db.getRepliesByUserId(userId);

      _userReplies = repliesData.map((data) {
        return CommentModel(
          id: data['id'].toString(),
          tweetId: data['tweetId'].toString(),
          author: UserModel(
            id: data['userId'].toString(),
            username: data['username'],
            displayName: data['displayName'],
            profileImage: data['profileImage'] ?? '',
            isVerified: data['isVerified'] == 1,
            joinDate: DateTime.now(),
          ),
          content: data['content'],
          createdAt: DateTime.parse(data['createdAt']),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading user replies: $e');
    }
  }

  Future<void> addComment(
    String tweetId,
    String content,
    UserModel user,
  ) async {
    try {
      final db = DatabaseHelper.instance;
      final commentId = await db.createComment({
        'tweetId': int.parse(tweetId),
        'userId': int.parse(user.id),
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final newComment = CommentModel(
        id: commentId.toString(),
        tweetId: tweetId,
        author: user,
        content: content,
        createdAt: DateTime.now(),
      );

      if (_comments[tweetId] == null) {
        _comments[tweetId] = [];
      }
      _comments[tweetId]!.add(newComment);

      // Update reply count on tweet
      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex != -1) {
        final tweet = _tweets[tweetIndex];
        _tweets[tweetIndex] = TweetModel(
          id: tweet.id,
          author: tweet.author,
          content: tweet.content,
          images: tweet.images,
          createdAt: tweet.createdAt,
          likes: tweet.likes,
          retweets: tweet.retweets,
          replies: tweet.replies + 1,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  // ... (existing methods: loadTweets, _generateDummyTweets, loadLikedTweets, addTweet, toggleLike, toggleRetweet, deleteTweet, isLiked, toggleBookmark)

  Future<void> loadTweets() async {
    try {
      final db = DatabaseHelper.instance;

      // Check if we need to seed initial data
      final hasTweets = await db.hasTweets();
      if (!hasTweets) {
        final dummyTweets = _generateDummyTweets();
        final tweetsToInsert = dummyTweets.map((t) {
          return {
            'userId': int.parse(t.author.id),
            'content': t.content,
            'images': t.images.join(','),
            'createdAt': t.createdAt.toIso8601String(),
            'likes': t.likes,
            'retweets': t.retweets,
            'replies': t.replies,
          };
        }).toList();

        // We also need to ensure the dummy users exist
        for (var tweet in dummyTweets) {
          final userExists = await db.getUserById(int.parse(tweet.author.id));
          if (userExists == null) {
            await db.createUser({
              'id': int.parse(tweet.author.id),
              'username': tweet.author.username,
              'displayName': tweet.author.displayName,
              'profileImage': tweet.author.profileImage,
              'isVerified': tweet.author.isVerified ? 1 : 0,
              'joinDate': tweet.author.joinDate.toIso8601String(),
              'email': '${tweet.author.username}@example.com', // Dummy email
              'password': 'password', // Dummy password
            });
          }
        }

        await db.batchInsertTweets(tweetsToInsert);
      }

      final tweetsData = await db.getAllTweets();

      _tweets = tweetsData.map((data) {
        return TweetModel(
          id: data['id'].toString(),
          author: UserModel(
            id: data['userId'].toString(),
            username: data['username'],
            displayName: data['displayName'],
            profileImage: data['profileImage'] ?? '',
            isVerified: data['isVerified'] == 1,
            joinDate: DateTime.now(),
          ),
          content: data['content'],
          images: data['images'] != null && data['images'].isNotEmpty
              ? (data['images'] as String).split(',')
              : [],
          createdAt: DateTime.parse(data['createdAt']),
          likes: data['likes'],
          retweets: data['retweets'],
          replies: data['replies'],
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading tweets: $e');
    }
  }

  List<TweetModel> _generateDummyTweets() {
    return [
      TweetModel(
        id: 'dummy_1',
        author: UserModel(
          id: '999',
          username: 'elonmusk',
          displayName: 'Elon Musk',
          profileImage: 'https://i.pravatar.cc/150?img=11',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'Just bought another company. Might delete later.',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        likes: 15400,
        retweets: 5400,
        replies: 1200,
      ),
      TweetModel(
        id: 'dummy_2',
        author: UserModel(
          id: '998',
          username: 'billgates',
          displayName: 'Bill Gates',
          profileImage: 'https://i.pravatar.cc/150?img=12',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'Coding is the new literacy. Everyone should learn to code.',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 8900,
        retweets: 2100,
        replies: 450,
      ),
      TweetModel(
        id: 'dummy_3',
        author: UserModel(
          id: '997',
          username: 'flutterdev',
          displayName: 'Flutter',
          profileImage: 'https://i.pravatar.cc/150?img=13',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Flutter 3.19 is out now! Check out the new features. 💙 #FlutterDev #Dart',
        images: ['https://picsum.photos/seed/flutter/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 5600,
        retweets: 1200,
        replies: 300,
      ),
      TweetModel(
        id: 'dummy_4',
        author: UserModel(
          id: '996',
          username: 'nasa',
          displayName: 'NASA',
          profileImage: 'https://i.pravatar.cc/150?img=14',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'The view from up here is amazing! 🌍🚀',
        images: ['https://picsum.photos/seed/space/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 25000,
        retweets: 8000,
        replies: 1500,
      ),
      TweetModel(
        id: 'dummy_5',
        author: UserModel(
          id: '995',
          username: 'googledev',
          displayName: 'Google Developers',
          profileImage: 'https://i.pravatar.cc/150?img=15',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Building amazing apps with #FlutterDev has never been easier! Join our community today.',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        likes: 3200,
        retweets: 890,
        replies: 156,
      ),
      TweetModel(
        id: 'dummy_6',
        author: UserModel(
          id: '994',
          username: 'kpuindonesia',
          displayName: 'KPU RI',
          profileImage: 'https://i.pravatar.cc/150?img=16',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Pemilu 2024 akan diselenggarakan dengan transparan dan akuntabel. Mari gunakan hak pilih Anda!',
        images: ['https://picsum.photos/seed/pemilu/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likes: 12000,
        retweets: 4500,
        replies: 2300,
      ),
      TweetModel(
        id: 'dummy_7',
        author: UserModel(
          id: '993',
          username: 'uefachampions',
          displayName: 'UEFA Champions League',
          profileImage: 'https://i.pravatar.cc/150?img=17',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'GOAL! What an incredible finish in the Liga Champion tonight! ⚽🏆',
        images: ['https://picsum.photos/seed/ucl/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 45000,
        retweets: 12000,
        replies: 3400,
      ),
      TweetModel(
        id: 'dummy_8',
        author: UserModel(
          id: '992',
          username: 'netflixid',
          displayName: 'Netflix Indonesia',
          profileImage: 'https://i.pravatar.cc/150?img=18',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Perfect weekend plans: grab some popcorn and enjoy #MovieNight with our latest releases! 🍿🎬',
        images: ['https://picsum.photos/seed/netflix/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        likes: 8700,
        retweets: 2100,
        replies: 890,
      ),
      TweetModel(
        id: 'dummy_9',
        author: UserModel(
          id: '991',
          username: 'androiddev',
          displayName: 'Android Developers',
          profileImage: 'https://i.pravatar.cc/150?img=19',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Cross-platform development with #FlutterDev means one codebase for Android and iOS! 🚀',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 15)),
        likes: 4300,
        retweets: 1100,
        replies: 234,
      ),
      TweetModel(
        id: 'dummy_10',
        author: UserModel(
          id: '990',
          username: 'politikindonesia',
          displayName: 'Politik Indonesia',
          profileImage: 'https://i.pravatar.cc/150?img=20',
          isVerified: false,
          joinDate: DateTime.now(),
        ),
        content:
            'Debat capres Pemilu 2024 akan segera dimulai. Siapa yang akan memenangkan hati rakyat?',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        likes: 5600,
        retweets: 1800,
        replies: 1200,
      ),
      TweetModel(
        id: 'dummy_11',
        author: UserModel(
          id: '989',
          username: 'realmadrid',
          displayName: 'Real Madrid C.F.',
          profileImage: 'https://i.pravatar.cc/150?img=21',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'Hala Madrid! Another victory in Liga Champion! 🏆⚪',
        images: ['https://picsum.photos/seed/madrid/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        likes: 67000,
        retweets: 18000,
        replies: 4500,
      ),
      TweetModel(
        id: 'dummy_12',
        author: UserModel(
          id: '988',
          username: 'imdb',
          displayName: 'IMDb',
          profileImage: 'https://i.pravatar.cc/150?img=22',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Top 10 movies for your #MovieNight this weekend. Which one will you watch first?',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        likes: 12000,
        retweets: 3400,
        replies: 890,
      ),
      TweetModel(
        id: 'dummy_13',
        author: UserModel(
          id: '987',
          username: 'dartlang',
          displayName: 'Dart Language',
          profileImage: 'https://i.pravatar.cc/150?img=23',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Dart 3.0 brings sound null safety to #FlutterDev. Write safer code today!',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        likes: 3800,
        retweets: 920,
        replies: 178,
      ),
      TweetModel(
        id: 'dummy_14',
        author: UserModel(
          id: '986',
          username: 'kompastv',
          displayName: 'Kompas TV',
          profileImage: 'https://i.pravatar.cc/150?img=24',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'BREAKING: Hasil quick count Pemilu 2024 mulai masuk. Pantau terus update terbaru!',
        images: ['https://picsum.photos/seed/kompas/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        likes: 23000,
        retweets: 8900,
        replies: 5600,
      ),
      TweetModel(
        id: 'dummy_15',
        author: UserModel(
          id: '985',
          username: 'fcbarcelona',
          displayName: 'FC Barcelona',
          profileImage: 'https://i.pravatar.cc/150?img=25',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'Visca Barça! Ready for the Liga Champion match tonight! 💙❤️',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        likes: 54000,
        retweets: 14000,
        replies: 3200,
      ),
      TweetModel(
        id: 'dummy_16',
        author: UserModel(
          id: '984',
          username: 'disneyplus',
          displayName: 'Disney+',
          profileImage: 'https://i.pravatar.cc/150?img=26',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'New Marvel series dropping this Friday! Perfect for #MovieNight 🦸‍♂️✨',
        images: ['https://picsum.photos/seed/disney/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        likes: 34000,
        retweets: 9800,
        replies: 2100,
      ),
      TweetModel(
        id: 'dummy_17',
        author: UserModel(
          id: '983',
          username: 'fluttercommunity',
          displayName: 'Flutter Community',
          profileImage: 'https://i.pravatar.cc/150?img=27',
          isVerified: false,
          joinDate: DateTime.now(),
        ),
        content:
            'Just published a new #FlutterDev tutorial on state management. Check it out!',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 22)),
        likes: 1200,
        retweets: 340,
        replies: 89,
      ),
      TweetModel(
        id: 'dummy_18',
        author: UserModel(
          id: '982',
          username: 'metrotv',
          displayName: 'Metro TV',
          profileImage: 'https://i.pravatar.cc/150?img=28',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Suasana TPS di berbagai daerah untuk Pemilu 2024. Antusiasme pemilih sangat tinggi!',
        images: ['https://picsum.photos/seed/metro/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 16)),
        likes: 8900,
        retweets: 2300,
        replies: 1100,
      ),
      TweetModel(
        id: 'dummy_19',
        author: UserModel(
          id: '981',
          username: 'espnfc',
          displayName: 'ESPN FC',
          profileImage: 'https://i.pravatar.cc/150?img=29',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'Liga Champion highlights: Top 5 goals from this week! ⚽🔥',
        images: ['https://picsum.photos/seed/espn/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
        likes: 28000,
        retweets: 7600,
        replies: 1800,
      ),
      TweetModel(
        id: 'dummy_20',
        author: UserModel(
          id: '980',
          username: 'hbomax',
          displayName: 'HBO Max',
          profileImage: 'https://i.pravatar.cc/150?img=30',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'Binge-worthy series for your #MovieNight marathon! 📺🍿',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 11)),
        likes: 15000,
        retweets: 4200,
        replies: 980,
      ),
    ];
  }

  Future<void> loadLikedTweets(int userId) async {
    try {
      _currentUserId = userId;
      final db = DatabaseHelper.instance;
      final likedData = await db.getLikedTweetsByUserId(userId);

      _likedTweetIds = likedData.map((data) => data['id'].toString()).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading liked tweets: $e');
    }
  }

  Future<void> addTweet(
    String content,
    UserModel author, {
    List<String>? images,
  }) async {
    try {
      final db = DatabaseHelper.instance;
      final userId = int.parse(author.id);

      final tweetId = await db.createTweet({
        'userId': userId,
        'content': content,
        'images': images?.join(',') ?? '',
        'createdAt': DateTime.now().toIso8601String(),
        'likes': 0,
        'retweets': 0,
        'replies': 0,
      });

      final newTweet = TweetModel(
        id: tweetId.toString(),
        author: author,
        content: content,
        images: images ?? [],
        createdAt: DateTime.now(),
        likes: 0,
        retweets: 0,
        replies: 0,
      );

      _tweets.insert(0, newTweet);
      notifyListeners();
    } catch (e) {
      print('Error adding tweet: $e');
    }
  }

  Future<void> toggleLike(String tweetId, int userId) async {
    try {
      final db = DatabaseHelper.instance;
      final tweetIdInt = int.parse(tweetId);
      final isLiked = await db.isTweetLiked(userId, tweetIdInt);

      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) return;

      final tweet = _tweets[tweetIndex];
      int newLikes;

      if (isLiked) {
        await db.unlikeTweet(userId, tweetIdInt);
        newLikes = tweet.likes - 1;
        _likedTweetIds.remove(tweetId);
      } else {
        await db.likeTweet(userId, tweetIdInt);
        newLikes = tweet.likes + 1;
        _likedTweetIds.add(tweetId);
      }

      await db.updateTweetLikes(tweetIdInt, newLikes);

      _tweets[tweetIndex] = TweetModel(
        id: tweet.id,
        author: tweet.author,
        content: tweet.content,
        images: tweet.images,
        createdAt: tweet.createdAt,
        likes: newLikes,
        retweets: tweet.retweets,
        replies: tweet.replies,
      );

      notifyListeners();
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> toggleRetweet(String tweetId) async {
    try {
      final db = DatabaseHelper.instance;
      final tweetIdInt = int.parse(tweetId);
      final userId = _currentUserId;

      if (userId == null) return;

      final isRetweeted = await db.isTweetRetweeted(userId, tweetIdInt);
      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) return;

      final tweet = _tweets[tweetIndex];
      int newRetweets;

      if (isRetweeted) {
        await db.unretweetTweet(userId, tweetIdInt);
        newRetweets = tweet.retweets - 1;
        _retweetedTweetIds.remove(tweetId);
      } else {
        await db.retweetTweet(userId, tweetIdInt);
        newRetweets = tweet.retweets + 1;
        _retweetedTweetIds.add(tweetId);
      }

      await db.updateTweetRetweets(tweetIdInt, newRetweets);

      _tweets[tweetIndex] = TweetModel(
        id: tweet.id,
        author: tweet.author,
        content: tweet.content,
        images: tweet.images,
        createdAt: tweet.createdAt,
        likes: tweet.likes,
        retweets: newRetweets,
        replies: tweet.replies,
      );

      notifyListeners();
    } catch (e) {
      print('Error toggling retweet: $e');
    }
  }

  Future<void> loadRetweetedTweets(int userId) async {
    try {
      final db = DatabaseHelper.instance;
      final retweetedData = await db.getRetweetedTweetsByUserId(userId);

      _retweetedTweetIds = retweetedData
          .map((data) => data['id'].toString())
          .toList();

      // Also store the full tweet models for display if needed
      _userRetweets = retweetedData.map((data) {
        return TweetModel(
          id: data['id'].toString(),
          author: UserModel(
            id: data['userId'].toString(),
            username: data['username'],
            displayName: data['displayName'],
            profileImage: data['profileImage'] ?? '',
            isVerified: data['isVerified'] == 1,
            joinDate: DateTime.now(),
          ),
          content: data['content'],
          images: data['images'] != null && data['images'].isNotEmpty
              ? (data['images'] as String).split(',')
              : [],
          createdAt: DateTime.parse(data['createdAt']),
          likes: data['likes'],
          retweets: data['retweets'],
          replies: data['replies'],
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading retweeted tweets: $e');
    }
  }

  Future<void> deleteTweet(String tweetId) async {
    try {
      final db = DatabaseHelper.instance;
      await db.deleteTweet(int.parse(tweetId));

      _tweets.removeWhere((t) => t.id == tweetId);
      notifyListeners();
    } catch (e) {
      print('Error deleting tweet: $e');
    }
  }

  bool isLiked(String tweetId) {
    return _likedTweetIds.contains(tweetId);
  }

  bool isRetweeted(String tweetId) {
    return _retweetedTweetIds.contains(tweetId);
  }

  void toggleBookmark(String id) {}
}
