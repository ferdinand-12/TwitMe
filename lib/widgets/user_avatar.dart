import 'dart:io';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const UserAvatar({Key? key, required this.imageUrl, this.size = 40})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey[300],
      backgroundImage: imageUrl.isNotEmpty
          ? (imageUrl.startsWith('http')
                ? NetworkImage(imageUrl) as ImageProvider
                : FileImage(File(imageUrl)))
          : null,
      child: imageUrl.isEmpty
          ? Icon(Icons.person, size: size / 2, color: Colors.grey[600])
          : null,
    );
  }
}
