import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../helpers/database_helper.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> init() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      final db = DatabaseHelper.instance;
      final userMap = await db.getUserByEmail(email);

      if (userMap == null) {
        return 'Email tidak ditemukan';
      }

      if (userMap['password'] != password) {
        return 'Password salah';
      }

      _currentUser = UserModel(
        id: userMap['id'].toString(),
        username: userMap['username'],
        displayName: userMap['displayName'],
        bio: userMap['bio'] ?? '',
        profileImage: userMap['profileImage'] ?? '',
        coverImage: userMap['coverImage'] ?? '',
        followers: userMap['followers'],
        following: userMap['following'],
        joinDate: DateTime.parse(userMap['joinDate']),
        isVerified: userMap['isVerified'] == 1,
      );

      _isAuthenticated = true;
      notifyListeners();
      return null; 
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      final db = DatabaseHelper.instance;

      final existingUser = await db.getUserByEmail(email);
      if (existingUser != null) {
        return 'Email sudah terdaftar';
      }

      final userId = await db.createUser({
        'username': username,
        'email': email,
        'password': password,
        'displayName': username,
        'bio': '',
        'profileImage': '',
        'coverImage': '',
        'followers': 0,
        'following': 0,
        'joinDate': DateTime.now().toIso8601String(),
        'isVerified': 0,
      });

      _currentUser = UserModel(
        id: userId.toString(),
        username: username,
        displayName: username,
        joinDate: DateTime.now(),
      );

      _isAuthenticated = true;
      notifyListeners();
      return null; 
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? profileImage,
    String? coverImage,
  }) async {
    if (_currentUser != null) {
      try {
        final db = DatabaseHelper.instance;
        final userId = int.parse(_currentUser!.id);

        await db.updateUser(userId, {
          'displayName': displayName ?? _currentUser!.displayName,
          'bio': bio ?? _currentUser!.bio,
          'profileImage': profileImage ?? _currentUser!.profileImage,
          'coverImage': coverImage ?? _currentUser!.coverImage,
        });

        _currentUser = UserModel(
          id: _currentUser!.id,
          username: _currentUser!.username,
          displayName: displayName ?? _currentUser!.displayName,
          bio: bio ?? _currentUser!.bio,
          profileImage: profileImage ?? _currentUser!.profileImage,
          coverImage: coverImage ?? _currentUser!.coverImage,
          followers: _currentUser!.followers,
          following: _currentUser!.following,
          joinDate: _currentUser!.joinDate,
          isVerified: _currentUser!.isVerified,
        );

        notifyListeners();
      } catch (e) {
        print('Error updating profile: $e');
      }
    }
  }
}
