import 'dart:io';

import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Screens/AddSongsToPlaylistPage.dart';
import 'package:looli_app/Screens/PlaylistDetailPage.dart';
import 'package:looli_app/services/liked_songs_service.dart';
import 'package:looli_app/widgets/dialog_utils.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/Screens/LikedSongsPage.dart';
import 'package:looli_app/Screens/CreatePlaylistPage.dart';
import 'package:looli_app/services/playlist_service.dart';
import 'package:looli_app/Models/playlist.dart'; // You can rename AlbumSongsPage to PlaylistSongsPage

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    playlists = await PlaylistService.getAllPlaylists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final likedSongs = LikedSongsService.getAllLiked();

    return Scaffold(
      backgroundColor: looliThird,
      appBar: AppBar(
        backgroundColor: looliThird,
        elevation: 0,
        title: const Text("Library", style: TextStyle(color: looliFourth)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 85),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Your Collection",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: looliFourth,
                  ),
                ),
                const SizedBox(height: 12),

                /// Liked Songs
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LikedSongsPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [looliFirst, looliSecond],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Liked Songs",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable:
                                    LikedSongsService.likedCountNotifier,
                                builder: (context, value, _) {
                                  return Text(
                                    "$value songs",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Playlist section
                const Text(
                  "Playlists",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: looliFourth,
                  ),
                ),
                const SizedBox(height: 10),

                if (playlists.isEmpty)
                  const Text(
                    "No playlists created yet.",
                    style: TextStyle(color: Colors.white54),
                  )
                else
                  ListView.builder(
                    itemCount: playlists.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PlaylistDetailPage(playlist: playlist),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: looliFourth,
                                ),
                                child:
                                    playlist.imagePath != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(playlist.imagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.queue_music,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  playlist.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    // Navigate to AddSongsToPlaylistPage
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => AddSongsToPlaylistPage(
                                              playlist: playlist,
                                            ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    showAnimatedConfirmDialog(
                                      context: context,
                                      title: "Delete Playlist",
                                      message:
                                          "Are you sure you want to delete this playlist?",
                                      onConfirmed: () async {
                                        final box = PlaylistService.getBox();
                                        await box.delete(playlist.key);
                                        setState(() {
                                          playlists.removeAt(index);
                                        });
                                      },
                                    );
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit Playlist'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete Playlist'),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),

                /// Add Playlist
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePlaylistPage(),
                      ),
                    );
                    loadPlaylists(); // Reload after creation
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white12),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white10,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.playlist_add, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          "Create Playlist",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Mini Player
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }
}
