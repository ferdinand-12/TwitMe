import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/database_helper.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_avatar.dart';
import 'message_detail_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({Key? key}) : super(key: key);

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final usersData = await DatabaseHelper.instance.getAllUsers(
      int.parse(currentUser.id),
    );
    setState(() {
      _users = usersData.map((data) => UserModel.fromJson(data)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Pengguna')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: UserAvatar(imageUrl: user.profileImage, size: 40),
                  title: Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('@${user.username}'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDetailScreen(
                          userName: user.displayName,
                          receiverId: int.parse(user.id),
                          username: user.username,
                          userImage: user.profileImage,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
