import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/user_avatar.dart';
import 'message_detail_screen.dart';
import 'settings_screen.dart';
import 'user_selection_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, _) {
          final conversations = messageProvider.conversations;

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mail_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pesan',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final isUnread = (conversation['unreadCount'] as int) > 0;

              return ListTile(
                leading: UserAvatar(
                  imageUrl: conversation['profileImage'] as String? ?? '',
                  size: 48,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation['displayName'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(conversation['lastMessageTime'] as String),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                subtitle: Text(
                  conversation['lastMessage'] as String,
                  style: TextStyle(
                    color: isUnread ? null : Colors.grey[600],
                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: isUnread
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1DA1F2),
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageDetailScreen(
                        receiverId: conversation['id'] as int,
                        userName: conversation['displayName'] as String,
                        username: conversation['username'] as String,
                        userImage:
                            conversation['profileImage'] as String? ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = context.read<AuthProvider>().currentUser;
          if (user == null) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSelectionScreen(),
            ),
          );
          if (context.mounted) {
            context.read<MessageProvider>().loadConversations(
              int.parse(user.id),
            );
          }
        },
        backgroundColor: const Color(0xFF1DA1F2),
        child: const Icon(Icons.mail_outline, color: Colors.white),
      ),
    );
  }

  String _formatTime(String isoString) {
    final date = DateTime.parse(isoString);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}hr';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}j';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'Baru saja';
    }
  }
}
