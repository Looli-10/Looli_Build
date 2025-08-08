
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  await Hive.openBox('profile');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ProfileHome(),
    );
  }
}

class ProfileHome extends StatefulWidget {
  const ProfileHome({super.key});

  @override
  State<ProfileHome> createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  final _profileBox = Hive.box('profile');

  void _pickAndSaveImageLocally() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _profileBox.put('imagePath', pickedFile.path);
      setState(() {});
    }
  }

  void _updateName(String name) {
    _profileBox.put('name', name);
    setState(() {});
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _profileBox.get('name', defaultValue: ''));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "New Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateName(nameController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _profileBox.get('imagePath');
    final name = _profileBox.get('name', defaultValue: "Looli User");
    final email = "looliuser@email.com";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Looli Sidebar Demo"),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          )
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 60),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: imagePath != null
                      ? FileImage(File(imagePath))
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                ),
                GestureDetector(
                  onTap: _pickAndSaveImageLocally,
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 15, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showEditNameDialog,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle logout logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout pressed')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: const Center(
        child: Text("Main App Content", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
