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
    body: Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // Header Section like ArtistSongsPage
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.songs.first.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.albumTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (widget.songs.isNotEmpty) {
                                  _playerManager.playSong(widget.songs[0], widget.songs);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("PLAY"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Songs List
              Expanded(
                child: ValueListenableBuilder<Song?>(
                  valueListenable: _playerManager.currentSongNotifier,
                  builder: (context, currentSong, _) {
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: widget.songs.length,
                      itemBuilder: (context, index) {
                        final song = widget.songs[index];
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
                                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song.artist,
                                        style: TextStyle(
                                          color: isPlaying ? Colors.white : Colors.white60,
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
            ],
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