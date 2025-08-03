import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/widgets/Song_Options.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/widgets/audio_manager.dart';

class AlbumSongsPage extends StatefulWidget {
  final String albumTitle;
  final List<Song> songs;

  const AlbumSongsPage({
    super.key,
    required this.albumTitle,
    required this.songs,
  });

  @override
  State<AlbumSongsPage> createState() => _AlbumSongsPageState();
}

class _AlbumSongsPageState extends State<AlbumSongsPage> {
  final _playerManager = PlayerManager();

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: Text(
        widget.albumTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
    ),
    body: Stack(
      children: [
        SafeArea(
          child: ValueListenableBuilder<Song?>(
            valueListenable: _playerManager.currentSongNotifier,
            builder: (context, currentSong, _) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: widget.songs.length + 1, // +1 for album image
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Album Image at top
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.songs.first.image,
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }

                  final song = widget.songs[index - 1];
                  final isPlaying = currentSong?.id == song.id;

                  return GestureDetector(
                    onTap: () async {
                      await _playerManager.playSong(song, widget.songs);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? Colors.white.withOpacity(0.15)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPlaying ? Colors.white30 : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: isPlaying
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.artist,
                                  style: TextStyle(
                                    color: isPlaying
                                        ? Colors.white
                                        : Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SongOptionsPopup(song: song, playlist: widget.songs),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MiniPlayer(),
        ),
      ],
    ),
  );
}
}