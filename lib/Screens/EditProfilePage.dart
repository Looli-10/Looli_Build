import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    final userBox = Hive.box('userBox');
    _nameController.text = userBox.get('customName', defaultValue: '') ?? '';
    _imageBytes = userBox.get('customImage');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _saveProfile() {
    final userBox = Hive.box('userBox');
    userBox.put('customName', _nameController.text.trim());
    if (_imageBytes != null) {
      userBox.put('customImage', _imageBytes);
    }
    Navigator.pop(context); // go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: looliFourth),
        title: const Text('Edit Profile', style: TextStyle(color: looliFourth)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageBytes != null ? MemoryImage(_imageBytes!) : null,
                child:
                    _imageBytes == null
                        ? const Icon(Icons.add_a_photo, size: 30)
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: looliFourth),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save', style: TextStyle(color: looliThird)),
              style: ElevatedButton.styleFrom(
                backgroundColor: looliFirst,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ))
          ]
        ),
      ),
    );
  }
}
