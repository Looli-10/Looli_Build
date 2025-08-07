import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Screens/PlayerPage.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/Models/songs.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final _player = PlayerManager().player;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Song?>(
      valueListenable: PlayerManager().currentSongNotifier,
      builder: (context, song, _) {
        if (song == null) return const SizedBox.shrink();

        double progress = (_duration.inMilliseconds > 0)
            ? _position.inMilliseconds / _duration.inMilliseconds
            : 0.0;

        return GestureDetector(
          onTap: () {
            final current = PlayerManager().currentSongNotifier.value;
            final playlist = PlayerManager().currentPlaylist;

            if (current != null && playlist.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerPage(
                    song: current,
                    playlist: playlist,
                    album: song.album,
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 65, vertical: 8),
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  // Background glass and gradient
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            looliFirst.withOpacity(0.15),
                            looliSecond.withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),

                  // Progress bar
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Song info and controls
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          song.image,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: looliFourth,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: const TextStyle(
                                color: looliFourth,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _player.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: looliFourth,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _player.playing ? _player.pause() : _player.play();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
