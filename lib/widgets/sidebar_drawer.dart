import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:looli_app/Screens/EditProfilePage.dart';

class SidebarDrawer extends StatelessWidget {
  final User? user;
  const SidebarDrawer({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');

    return Drawer(
      backgroundColor: Colors.black,
      child: ValueListenableBuilder(
        valueListenable: userBox.listenable(),
        builder: (context, Box box, _) {
          final customName = box.get('customName', defaultValue: null);
          final customImage = box.get('customImage', defaultValue: null);

          final displayName = customName ?? user?.email ?? "Looli User";
          final showEmail = customName != null;

          return Column(
            children: [
              const SizedBox(height: 60),
              CircleAvatar(
                radius: 40,
                backgroundImage: customImage != null
                    ? MemoryImage(customImage)
                    : user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/profile-user.png')
                            as ImageProvider,
              ),
              const SizedBox(height: 10),
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (showEmail)
                const SizedBox(height: 5),
              if (showEmail)
                Text(
                  user?.email ?? "",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Edit Profile',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Logout',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
