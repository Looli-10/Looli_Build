import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static Future<void> checkForUpdates(BuildContext context) async {
    final url = 'https://looli-10.github.io/Looli_Build/update.json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final latestVersion = data['latestVersion'];
      final apkUrl = data['apkUrl'];
      final updateMessage = data['updateMessage'];

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (latestVersion != currentVersion) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Update Available"),
                content: Text(updateMessage),
                actions: [
                  TextButton(
                    child: const Text("Later"),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  TextButton(
                    child: const Text("Update"),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      if (await canLaunch(apkUrl)) {
                        await launch(apkUrl);
                      }
                    },
                  ),
                ],
              ),
        );
      }
    }
  }
}
