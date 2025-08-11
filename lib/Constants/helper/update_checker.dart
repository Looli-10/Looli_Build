import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // Get latest version from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('updates')
          .doc('latest')
          .get();

      if (!doc.exists) return;

      String latestVersion = doc['version'];
      String downloadUrl = doc['url'];

      // Compare versions
      if (_isNewVersion(latestVersion, currentVersion)) {
        _showUpdateDialog(context, latestVersion, downloadUrl);
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static bool _isNewVersion(String latest, String current) {
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

  static void _showUpdateDialog(
      BuildContext context, String version, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Available"),
        content: Text("A new version ($version) is available."),
        actions: [
          TextButton(
            child: Text("Later"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Update"),
            onPressed: () async {
              Navigator.pop(context);
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }
}
