import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/widgets/Song_Options.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/widgets/mini_player.dart';

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

class _ArtistSongsPageState extends State<ArtistSongsPage> with TickerProviderStateMixin {
  final PlayerManager _playerManager = PlayerManager();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Song> _filteredSongs = [];
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.songs;
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSongs = widget.songs.where((song) {
        return song.title.toLowerCase().contains(query) || song.album.toLowerCase().contains(query);
      }).toList();

      _filteredSongs.sort((a, b) => _isAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header Section
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.artistImage),
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
                            widget.artist,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "711,149 Followers",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_filteredSongs.isNotEmpty) {
                                    _playerManager.playSong(_filteredSongs[0], widget.songs);
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

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPopularTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mini Player
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
        ],
      ),
    );
  }

  Widget _buildPopularTab() {
    return Column(
      children: [
        // Search Field
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
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined,
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

        // Songs List
        Expanded(
          child: ValueListenableBuilder<Song?>(
            valueListenable: _playerManager.currentSongNotifier,
            builder: (context, currentSong, _) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                itemCount: _filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = _filteredSongs[index];
                  final isPlaying = currentSong?.id == song.id;

                  return GestureDetector(
                    onTap: () async {
                      await _playerManager.playSong(song, widget.songs);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPlaying ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPlaying ? Colors.white30 : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              song.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note, color: Colors.white54),
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
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
