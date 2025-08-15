import 'dart:io';

import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/Queue_service.dart';
import 'package:looli_app/services/playlist_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';

class SongOptionsPopup extends StatelessWidget {
  final Song song;
  final List<Song> playlist;

  const SongOptionsPopup({
    super.key,
    required this.song,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        if (value == 'play') {
          await PlayerManager().playSong(song, playlist);
        } else if (value == 'queue') {
          await PlayerManager().appendToQueue([song]);
          await QueueService().addToQueue(song);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${song.title} added to queue')),
          );
        } else if (value == 'add_to_playlist') {
          _showPlaylistSelection(context);
        }
      },
      itemBuilder:
          (context) => const [
            PopupMenuItem(value: 'play', child: Text('Play')),
            PopupMenuItem(value: 'queue', child: Text('Add to Queue')),
            PopupMenuItem(
              value: 'add_to_playlist',
              child: Text('Add to Playlist'),
            ), // ✅ New Option
          ],
    );
  }
  void _showPlaylistSelection(BuildContext context) async {
  final playlists = await PlaylistService.getAllPlaylists();

  if (playlists.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No playlists available.")),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          "Select Playlist",
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                leading: playlist.imageUrl != null
                    ? Image.file(File(playlist.imageUrl!), width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.queue_music, color: Colors.white),
                title: Text(
                  playlist.name,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  playlist.songs.add(song);
                  await playlist.save(); // Hive updates the existing playlist
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Added to ${playlist.name}")),
                  );
                },
              );
            },
          ),
        ),
      );
    },
  );
}

}
