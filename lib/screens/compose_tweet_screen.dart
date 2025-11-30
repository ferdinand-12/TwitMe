import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/tweet_provider.dart';
import '../widgets/user_avatar.dart';

class ComposeTweetScreen extends StatefulWidget {
  const ComposeTweetScreen({Key? key}) : super(key: key);

  @override
  State<ComposeTweetScreen> createState() => _ComposeTweetScreenState();
}

class _ComposeTweetScreenState extends State<ComposeTweetScreen> {
  final _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _postTweet() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isPosting = true);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      context.read<TweetProvider>().addTweet(_controller.text, []);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isPosting ? null : _postTweet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DA1F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isPosting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Tweet',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(imageUrl: user?.profileImage ?? '', size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Ada yang baru?',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!
                  : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined, color: Color(0xFF1DA1F2)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.gif_box_outlined, color: Color(0xFF1DA1F2)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.poll_outlined, color: Color(0xFF1DA1F2)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined,
                  color: Color(0xFF1DA1F2)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.schedule_outlined, color: Color(0xFF1DA1F2)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.location_on_outlined,
                  color: Color(0xFF1DA1F2)),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}