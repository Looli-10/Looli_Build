import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/playlist.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/playlist_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/Screens/PlayerPage.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/Screens/AddSongsToPlaylistPage.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  String searchQuery = '';
  bool sortAscending = true;

  List<Song> get filteredSongs {
    final songs =
        widget.playlist.songs
            .where(
              (s) => s.title.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    songs.sort(
      (a, b) =>
          sortAscending
              ? a.title.compareTo(b.title)
              : b.title.compareTo(a.title),
    );

    return songs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full background image
          widget.playlist.imageUrl != null &&
                  File(widget.playlist.imageUrl!).existsSync()
              ? Image.file(File(widget.playlist.imageUrl!), fit: BoxFit.cover)
              : Container(color: Colors.grey[900]),

          // Full page blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // Foreground content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: looliFourth),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.sort_by_alpha, color: Colors.white),
                    tooltip: "Sort",
                    onPressed: () {
                      setState(() {
                        sortAscending = !sortAscending;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: "Add Songs",
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AddSongsToPlaylistPage(
                                playlist: widget.playlist,
                              ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.playlist.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  background: Center(
                    child:
                        widget.playlist.imageUrl != null &&
                                File(widget.playlist.imageUrl!).existsSync()
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(widget.playlist.imageUrl!),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[800],
                            ),
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      hintText: "Search songs...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              // Song list
              filteredSongs.isEmpty
                  ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No songs found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                  : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = filteredSongs[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            song.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(
                            color: looliFourth,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            final box = PlaylistService.getBox();
                            final currentPlaylist = box.get(
                              widget.playlist.key,
                            );
                            if (currentPlaylist != null) {
                              currentPlaylist.songs.removeWhere(
                                (s) => s.id == song.id,
                              );
                              await currentPlaylist.save();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => PlaylistDetailPage(
                                        playlist: currentPlaylist,
                                      ),
                                ),
                              );
                            }
                          },
                        ),
                        onTap: () async {
                          final manager = PlayerManager();
                          await manager.playSong(song, widget.playlist.songs);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PlayerPage(
                                    song: song,
                                    playlist: widget.playlist.songs,
                                    album: widget.playlist.name,
                                  ),
                            ),
                          );
                        },
                      );
                    }, childCount: filteredSongs.length),
                  ),

              // Bottom space for mini player
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
