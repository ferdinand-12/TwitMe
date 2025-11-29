import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/tweet_provider.dart';
import '../providers/auth_provider.dart';

class ComposeTweetScreen extends StatefulWidget {
  const ComposeTweetScreen({Key? key}) : super(key: key);

  @override
  State<ComposeTweetScreen> createState() => _ComposeTweetScreenState();
}

class _ComposeTweetScreenState extends State<ComposeTweetScreen> {
  final _tweetController = TextEditingController();
  final List<String> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _tweetController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final emoji = String.fromCharCode(0x1F600 + index);
              return GestureDetector(
                onTap: () {
                  _tweetController.text += emoji;
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _postTweet() async {
    if (_tweetController.text.isEmpty && _selectedImages.isEmpty) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    await context.read<TweetProvider>().addTweet(
      _tweetController.text,
      user,
      images: _selectedImages,
    );

    if (mounted) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: _postTweet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DA1F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Tweet'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      user?.profileImage ?? 'https://i.pravatar.cc/150?img=1',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _tweetController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Apa yang sedang terjadi?',
                            border: InputBorder.none,
                          ),
                        ),
                        if (_selectedImages.isNotEmpty)
                          Container(
                            height: 100,
                            margin: const EdgeInsets.only(top: 10),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(_selectedImages[index]),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF1DA1F2),
                  ),
                  onPressed: _pickImages,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Color(0xFF1DA1F2),
                  ),
                  onPressed: _showEmojiPicker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
