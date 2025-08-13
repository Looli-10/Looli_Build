import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/widgets/Song_Options.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added caching

class ArtistSongsPage extends StatefulWidget {
  final String artist;
  final List<Song> songs;
  final String artistImage;

  const ArtistSongsPage({
    super.key,
    required this.artist,
    required this.songs,
    required this.artistImage,
  });

  @override
  State<ArtistSongsPage> createState() => _ArtistSongsPageState();
}

class _ArtistSongsPageState extends State<ArtistSongsPage> {
  final PlayerManager _playerManager = PlayerManager();
  final TextEditingController _searchController = TextEditingController();
  List<Song> _filteredSongs = [];
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.songs;
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    final filtered =
        widget.songs.where((song) {
          return song.title.toLowerCase().contains(query) ||
              song.album.toLowerCase().contains(query);
        }).toList();

    filtered.sort(
      (a, b) =>
          _isAscending
              ? a.title.compareTo(b.title)
              : b.title.compareTo(a.title),
    );

    if (_filteredSongs != filtered) {
      setState(() => _filteredSongs = filtered);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSongTile(Song song, bool isPlaying) {
    return GestureDetector(
      onTap: () async {
        await _playerManager.playSong(song, widget.songs);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isPlaying
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying ? Colors.white30 : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: song.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        const Icon(Icons.music_note, color: Colors.white54),
                errorWidget:
                    (context, url, error) =>
                        const Icon(Icons.music_note, color: Colors.white54),
              ),
            ),
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
                    song.album,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 300.0,
                    pinned: true,
                    backgroundColor: Colors.black,
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      collapseMode: CollapseMode.parallax,
                      title: Text(
                        widget.artist,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.artistImage,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    Container(color: Colors.black26),
                            errorWidget:
                                (context, url, error) =>
                                    Container(color: Colors.black26),
                          ),
                          Container(
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
                        ],
                      ),
                    ),
                  ),
                ],
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Play button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_filteredSongs.isNotEmpty) {
                        _playerManager.playSong(
                          _filteredSongs[0],
                          widget.songs,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("PLAY"),
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search songs...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isAscending
                              ? Icons.sort_by_alpha
                              : Icons.sort_by_alpha_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _isAscending = !_isAscending);
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                ),

                // Song list
                ValueListenableBuilder<Song?>(
                  valueListenable: _playerManager.currentSongNotifier,
                  builder: (context, currentSong, _) {
                    return Column(
                      children:
                          _filteredSongs.map((song) {
                            final isPlaying = currentSong?.id == song.id;
                            return _buildSongTile(song, isPlaying);
                          }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // Mini player stays fixed and doesn't rebuild with scroll
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }
}
