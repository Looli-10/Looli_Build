import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/Liked_songs_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/services/queue_service.dart';

class PlayerPage extends StatefulWidget {
  final Song song;
  final List<Song> playlist;

  const PlayerPage({
    super.key,
    required this.song,
    required this.playlist,
    required album,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final _manager = PlayerManager();
  late final _player = _manager.player;

  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
    _listenToPlayer();
  }

  void _init() async {
    if (_player.playing) return; // Don't interrupt

    await _manager.setPlaylist(
      widget.playlist,
      startIndex: widget.playlist.indexWhere((s) => s.id == widget.song.id),
    );

    // If there's a queue, append it
    final queue = await QueueService().getQueue();
    if (queue.isNotEmpty) {
      await _manager.appendToQueue(queue);
    }
  }

  void _listenToPlayer() {
    _player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    _player.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => isPlaying = state.playing);
      }
    });
  }

  void _togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  void _toggleRepeat() => _manager.toggleRepeat();
  void _toggleShuffle() => _manager.toggleShuffle();
  void _nextSong() => _manager.playNext();
  void _previousSong() => _manager.playPrevious();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: looliThird,
      extendBodyBehindAppBar: true,
      body: ValueListenableBuilder<Song?>(
        valueListenable: _manager.currentSongNotifier,
        builder: (context, currentSong, _) {
          if (currentSong == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10.h),
                  Text(
                    "Playing from\n${currentSong.album}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      currentSong.image,
                      height: 320.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  /// Glass container with player controls
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              currentSong.title,
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              currentSong.artist,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 20.h),

                            /// Slider
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white38,
                                trackHeight: 4,
                                thumbColor: Colors.white,
                                overlayColor: Colors.white24,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                              ),
                              child: Slider(
                                value:
                                    _duration.inSeconds > 0
                                        ? _position.inSeconds
                                            .clamp(0, _duration.inSeconds)
                                            .toDouble()
                                        : 0.0,
                                min: 0,
                                max:
                                    _duration.inSeconds > 0
                                        ? _duration.inSeconds.toDouble()
                                        : 1.0,
                                onChanged: (value) {
                                  _player.seek(
                                    Duration(seconds: value.toInt()),
                                  );
                                },
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_position),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_duration),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15.h),

                            /// Playback Controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.skip_previous),
                                  color: Colors.white,
                                  iconSize: 38,
                                  onPressed: _previousSong,
                                ),
                                SizedBox(width: 20.w),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    color: looliSixth,
                                    iconSize: 38,
                                    onPressed: _togglePlayback,
                                  ),
                                ),
                                SizedBox(width: 20.w),
                                IconButton(
                                  icon: const Icon(Icons.skip_next),
                                  color: Colors.white,
                                  iconSize: 38,
                                  onPressed: _nextSong,
                                ),
                              ],
                            ),

                            SizedBox(height: 15.h),

                            /// Repeat & Shuffle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Repeat Button
                                ValueListenableBuilder(
                                  valueListenable: _manager.repeatModeNotifier,
                                  builder: (_, mode, __) {
                                    IconData icon =
                                        mode == LoopMode.one
                                            ? Icons.repeat_one
                                            : Icons.repeat;
                                    return IconButton(
                                      icon: Icon(icon),
                                      color:
                                          mode == LoopMode.off
                                              ? Colors.white30
                                              : Colors.white,
                                      onPressed: _toggleRepeat,
                                    );
                                  },
                                ),

                                // Like Button (new center item)
                                IconButton(
                                  icon: Icon(
                                    LikedSongsService.isLiked(currentSong.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        LikedSongsService.isLiked(
                                              currentSong.id,
                                            )
                                            ? Colors.red
                                            : Colors.white30,
                                  ),
                                  onPressed: () async {
                                    if (LikedSongsService.isLiked(
                                      currentSong.id,
                                    )) {
                                      await LikedSongsService.unlikeSong(
                                        currentSong.id,
                                      );
                                    } else {
                                      await LikedSongsService.likeSong(
                                        currentSong,
                                      );
                                    }
                                    setState(() {});
                                  },
                                ),

                                // Shuffle Button
                                ValueListenableBuilder(
                                  valueListenable: _manager.shuffleModeNotifier,
                                  builder: (_, isShuffled, __) {
                                    return IconButton(
                                      icon: const Icon(Icons.shuffle),
                                      color:
                                          isShuffled
                                              ? Colors.white
                                              : Colors.white30,
                                      onPressed: _toggleShuffle,
                                    );
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            /// 🎵 Queue Preview
                            /// 🎵 Queue List (Vertical with remove)
                            /// 🎵 Queue Preview (Vertical with remove option)
                            FutureBuilder<List<Song>>(
                              future: QueueService().getQueue(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  print(
                                    "count of songs in queue: ${snapshot.data}",
                                  );
                                  return const SizedBox.shrink();
                                }

                                final queue = snapshot.data!;
                                final currentId =
                                    PlayerManager()
                                        .currentSongNotifier
                                        .value
                                        ?.id;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 30),
                                    const Text(
                                      'Up Next',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ReorderableListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: queue.length,
                                      onReorder: (oldIndex, newIndex) async {
                                        // Adjust the newIndex if dragging down
                                        if (newIndex > oldIndex) newIndex--;

                                        final updatedQueue = List<Song>.from(
                                          queue,
                                        );
                                        final song = updatedQueue.removeAt(
                                          oldIndex,
                                        );
                                        updatedQueue.insert(newIndex, song);

                                        // Overwrite Isar queue with new order
                                        final service = QueueService();
                                        await service.clearQueue();
                                        for (final s in updatedQueue) {
                                          await service.addToQueue(s);
                                        }

                                        // Rebuild the UI
                                        setState(() {});
                                      },
                                      itemBuilder: (context, index) {
                                        final song = queue[index];
                                        final isPlaying = song.id == currentId;

                                        return ListTile(
                                          key: ValueKey(song.id),
                                          contentPadding: EdgeInsets.zero,
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              song.image,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          title: Text(
                                            song.title,
                                            style: TextStyle(
                                              color:
                                                  isPlaying
                                                      ? looliSecond
                                                      : looliFourth,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            song.artist,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                          onTap: () async {
                                            final player = PlayerManager();
                                            final fullList =
                                                player.currentPlaylist;

                                            final matchIndex = fullList
                                                .indexWhere(
                                                  (s) => s.id == song.id,
                                                );
                                            if (matchIndex != -1) {
                                              await player.playSong(
                                                fullList[matchIndex],
                                                fullList,
                                              );
                                            } else {
                                              await player.playSong(song, [
                                                song,
                                              ]);
                                            }

                                            player.currentSongNotifier.value =
                                                song; // ✅ Only once
                                            setState(() {});
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
