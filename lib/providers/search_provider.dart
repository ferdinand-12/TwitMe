import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/tweet_model.dart';

class SearchProvider with ChangeNotifier {
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<UserModel> searchUsers(List<UserModel> allUsers) {
    if (_searchQuery.isEmpty) return [];

    final query = _searchQuery.toLowerCase();
    return allUsers.where((user) {
      return user.username.toLowerCase().contains(query) ||
          user.displayName.toLowerCase().contains(query);
    }).toList();
  }

  List<TweetModel> searchTweets(List<TweetModel> allTweets) {
    if (_searchQuery.isEmpty) return [];

    final query = _searchQuery.toLowerCase();
    return allTweets.where((tweet) {
      return tweet.content.toLowerCase().contains(query) ||
          tweet.author.username.toLowerCase().contains(query) ||
          tweet.author.displayName.toLowerCase().contains(query);
    }).toList();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
