import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:looli_app/Constants/helper/update_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:looli_app/Screens/EditProfilePage.dart';

class SidebarDrawer extends StatefulWidget {
  final User? user;
  const SidebarDrawer({super.key, this.user});

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer> {
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdateBadge();
  }

  Future<void> _checkForUpdateBadge() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      FirebaseFirestore.instance
          .collection('updates')
          .doc('latest')
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          String latestVersion = doc['version'];
          if (_isNewVersion(latestVersion, currentVersion)) {
            setState(() {
              _updateAvailable = true;
            });
          } else {
            setState(() {
              _updateAvailable = false;
            });
          }
        }
      });
    } catch (e) {
      debugPrint("Badge check failed: $e");
    }
  }

  bool _isNewVersion(String latest, String current) {
    List<int> latestParts = latest.split('.').map(int.parse).toList();
    List<int> currentParts = current.split('.').map(int.parse).toList();
    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      } else if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

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

          final displayName = customName ?? widget.user?.email ?? "Looli User";
          final showEmail = customName != null;

          return Column(
            children: [
              const SizedBox(height: 60),
              CircleAvatar(
                radius: 40,
                backgroundImage: customImage != null
                    ? MemoryImage(customImage)
                    : widget.user?.photoURL != null
                        ? NetworkImage(widget.user!.photoURL!)
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
                  widget.user?.email ?? "",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              const Spacer(),

              // Edit Profile
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

              // 🔔 Check for Updates with badge
              ListTile(
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.system_update, color: Colors.white),
                    if (_updateAvailable)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                title: const Text('Check for Updates',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  UpdateChecker.checkForUpdate(context);
                },
              ),

              // Logout
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
