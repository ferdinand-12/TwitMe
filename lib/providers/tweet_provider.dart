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
          isLiked: tweet.isLiked,
          isRetweeted: tweet.isRetweeted,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<void> loadTweets() async {
    try {
      final db = DatabaseHelper.instance;

      final dummyUserExists = await db.getUserById(999);
      if (dummyUserExists == null) {
        final dummyTweets = _generateDummyTweets();

        for (var tweet in dummyTweets) {
          final userId = int.parse(tweet.author.id);
          final userExists = await db.getUserById(userId);
          if (userExists == null) {
            await db.createUser({
              'id': userId,
              'username': tweet.author.username,
              'displayName': tweet.author.displayName,
              'profileImage': tweet.author.profileImage,
              'isVerified': tweet.author.isVerified ? 1 : 0,
              'joinDate': tweet.author.joinDate.toIso8601String(),
              'email': '${tweet.author.username}@example.com',
              'password': 'password',
              'bio': null,
              'coverImage': null,
              'followers': 0,
              'following': 0,
            });
          }
        }

        // Then insert tweets
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

        await db.batchInsertTweets(tweetsToInsert);
      }

      final tweetsData = await db.getAllTweets();

      _tweets = tweetsData.map((data) {
        final tweetId = data['id'].toString();
        return TweetModel(
          id: tweetId,
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
          isLiked: _likedTweetIds.contains(tweetId),
          isRetweeted: _retweetedTweetIds.contains(tweetId),
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        content: 'Flutter 3.19 is out now! Check out the new features. 💙',
        images: ['https://picsum.photos/seed/flutter/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
            'Building amazing apps with Flutter has never been easier! Join our community today.',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
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
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_21',
        author: UserModel(
          id: '979',
          username: 'techcrunch',
          displayName: 'TechCrunch',
          profileImage: 'https://i.pravatar.cc/150?img=31',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Breaking: New AI breakthrough announced today! The future is here. 🤖',
        images: ['https://picsum.photos/seed/tech/400/200'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_22',
        author: UserModel(
          id: '978',
          username: 'spotify',
          displayName: 'Spotify',
          profileImage: 'https://i.pravatar.cc/150?img=32',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Your 2024 Wrapped is ready! Check out your top songs of the year 🎵',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_23',
        author: UserModel(
          id: '977',
          username: 'premierleague',
          displayName: 'Premier League',
          profileImage: 'https://i.pravatar.cc/150?img=33',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'What a match! The title race is heating up! ⚽🔥',
        images: ['https://picsum.photos/seed/epl/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_24',
        author: UserModel(
          id: '976',
          username: 'apple',
          displayName: 'Apple',
          profileImage: 'https://i.pravatar.cc/150?img=34',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Introducing the new iPhone 16 Pro. The most powerful iPhone ever. 📱✨',
        images: ['https://picsum.photos/seed/apple/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_25',
        author: UserModel(
          id: '975',
          username: 'bbcnews',
          displayName: 'BBC News',
          profileImage: 'https://i.pravatar.cc/150?img=35',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'BREAKING: Major climate agreement reached at global summit 🌍',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_26',
        author: UserModel(
          id: '974',
          username: 'instagram',
          displayName: 'Instagram',
          profileImage: 'https://i.pravatar.cc/150?img=36',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'New feature alert! Now you can share your favorite moments with friends 📸',
        images: ['https://picsum.photos/seed/insta/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_27',
        author: UserModel(
          id: '973',
          username: 'therock',
          displayName: 'Dwayne Johnson',
          profileImage: 'https://i.pravatar.cc/150?img=37',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Just finished an amazing workout! Remember, success starts with discipline 💪',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_28',
        author: UserModel(
          id: '972',
          username: 'cnnbreaking',
          displayName: 'CNN Breaking News',
          profileImage: 'https://i.pravatar.cc/150?img=38',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Live updates: Major developments in international relations today',
        images: ['https://picsum.photos/seed/cnn/400/200'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_29',
        author: UserModel(
          id: '971',
          username: 'youtube',
          displayName: 'YouTube',
          profileImage: 'https://i.pravatar.cc/150?img=39',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content:
            'Creators are making amazing content every day. What will you create? 🎬',
        images: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
      TweetModel(
        id: 'dummy_30',
        author: UserModel(
          id: '970',
          username: 'spacex',
          displayName: 'SpaceX',
          profileImage: 'https://i.pravatar.cc/150?img=40',
          isVerified: true,
          joinDate: DateTime.now(),
        ),
        content: 'Successful launch! Next stop: Mars 🚀🔴',
        images: ['https://picsum.photos/seed/spacex/400/200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        likes: 0,
        retweets: 0,
        replies: 0,
      ),
    ];
  }

  Future<void> loadLikedTweets(int userId) async {
    try {
      _currentUserId = userId;
      final db = DatabaseHelper.instance;
      final likedData = await db.getLikedTweetsByUserId(userId);

      _likedTweetIds = likedData.map((data) => data['id'].toString()).toList();

      // Also load retweeted tweets
      await loadRetweetedTweets(userId);

      // Reload tweets to update their isLiked and isRetweeted states
      await loadTweets();

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
      int tweetIdInt;
      try {
        tweetIdInt = int.parse(tweetId);
      } catch (e) {
        print('Invalid tweet ID for like: $tweetId');
        return;
      }
      final isLiked = await db.isTweetLiked(userId, tweetIdInt);

      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) return;

      final tweet = _tweets[tweetIndex];
      int newLikes;
      bool newIsLiked;

      if (isLiked) {
        await db.unlikeTweet(userId, tweetIdInt);
        newLikes = tweet.likes - 1;
        newIsLiked = false;
        _likedTweetIds.remove(tweetId);
      } else {
        await db.likeTweet(userId, tweetIdInt);
        newLikes = tweet.likes + 1;
        newIsLiked = true;
        _likedTweetIds.add(tweetId);
      }

      await db.updateTweetLikes(tweetIdInt, newLikes);

      final newTweet = TweetModel(
        id: tweet.id,
        author: tweet.author,
        content: tweet.content,
        images: tweet.images,
        createdAt: tweet.createdAt,
        likes: newLikes,
        retweets: tweet.retweets,
        replies: tweet.replies,
        isLiked: newIsLiked,
        isRetweeted: tweet.isRetweeted,
      );

      _tweets[tweetIndex] = newTweet;

      // Also update in userRetweets if it exists there
      final retweetIndex = _userRetweets.indexWhere((t) => t.id == tweetId);
      if (retweetIndex != -1) {
        _userRetweets[retweetIndex] = newTweet;
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> toggleRetweet(String tweetId, int userId) async {
    try {
      final db = DatabaseHelper.instance;
      int tweetIdInt;
      try {
        tweetIdInt = int.parse(tweetId);
      } catch (e) {
        print('Invalid tweet ID for retweet: $tweetId');
        return;
      }

      final isRetweeted = await db.isTweetRetweeted(userId, tweetIdInt);
      final tweetIndex = _tweets.indexWhere((t) => t.id == tweetId);
      if (tweetIndex == -1) return;

      final tweet = _tweets[tweetIndex];
      int newRetweets;
      bool newIsRetweeted;

      if (isRetweeted) {
        newRetweets = tweet.retweets - 1;
        newIsRetweeted = false;
      } else {
        newRetweets = tweet.retweets + 1;
        newIsRetweeted = true;
      }

      final newTweet = TweetModel(
        id: tweet.id,
        author: tweet.author,
        content: tweet.content,
        images: tweet.images,
        createdAt: tweet.createdAt,
        likes: tweet.likes,
        retweets: newRetweets,
        replies: tweet.replies,
        isLiked: tweet.isLiked,
        isRetweeted: newIsRetweeted,
      );

      _tweets[tweetIndex] = newTweet;

      if (isRetweeted) {
        await db.unretweetTweet(userId, tweetIdInt);
        _retweetedTweetIds.remove(tweetId);
        _userRetweets.removeWhere((t) => t.id == tweetId);
      } else {
        await db.retweetTweet(userId, tweetIdInt);
        _retweetedTweetIds.add(tweetId);
        _userRetweets.add(newTweet);
      }

      await db.updateTweetRetweets(tweetIdInt, newRetweets);

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
