import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _displayNameController = TextEditingController(
      text: user?.displayName ?? '',
    );
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthProvider>().updateProfile(
        displayName: _displayNameController.text,
        bio: _bioController.text,
        profileImage: _profileImage?.path,
        coverImage: _coverImage?.path,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
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
        title: const Text('Edit Profil'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: 80,
              child: CustomButton(text: 'Simpan', onPressed: _saveProfile),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Cover Image Preview
            Stack(
              children: [
                GestureDetector(
                  onTap: _pickCoverImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: _coverImage != null
                        ? Image.file(
                            _coverImage!,
                            fit: BoxFit.cover,
                          )
                        : (user?.coverImage != null && user!.coverImage.isNotEmpty)
                            ? (user.coverImage.startsWith('http')
                                ? Image.network(
                                    user.coverImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.add_photo_alternate, size: 40),
                                        ),
                                      );
                                    },
                                  )
                                : Image.file(
                                    File(user.coverImage),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.add_photo_alternate, size: 40),
                                        ),
                                      );
                                    },
                                  ))
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Tambah Foto Sampul', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[400],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : (user?.profileImage != null && user!.profileImage.isNotEmpty)
                                ? (user.profileImage.startsWith('http')
                                    ? NetworkImage(user.profileImage) as ImageProvider
                                    : FileImage(File(user.profileImage)))
                                : null,
                        child: (_profileImage == null && 
                               (user?.profileImage == null || user!.profileImage.isEmpty))
                            ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Display Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            // Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 160,
              ),
            ),

            const SizedBox(height: 24),

            // User Info (Read-only)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Akun',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Username'),
                    subtitle: Text('@${user?.username ?? ''}'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bergabung'),
                    subtitle: Text(
                      _formatDate(user?.joinDate ?? DateTime.now()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
