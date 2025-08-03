import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/PlayerPage.dart';
import 'package:looli_app/widgets/ArtistListSection.dart';
import 'package:looli_app/widgets/FullAlbumGridSection.dart';
import 'package:looli_app/widgets/Song_Options.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/widgets/mini_player.dart';

class SearchPage extends StatefulWidget {
  final List<Song> allSongs;
  final VoidCallback onBackToHome;
  final Map<String, String> artistImageMap;

  const SearchPage({
    super.key,
    required this.allSongs,
    required this.onBackToHome,
    required this.artistImageMap,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  String query = '';
  int selectedTabIndex = 0;
  List<Song> filteredSongs = [];
  List<String> filteredAlbums = [];
  List<MapEntry<String, String>> filteredArtists = [];

  @override
  void initState() {
    super.initState();
    filteredSongs = widget.allSongs;
    filteredAlbums = widget.allSongs.map((song) => song.album).toSet().toList();
    filteredArtists = widget.artistImageMap.entries.toList();
  }

  void updateSearch(String newQuery) {
    setState(() {
      query = newQuery.toLowerCase();

      if (selectedTabIndex == 0) {
        filteredSongs = widget.allSongs.where((song) {
          return song.title.toLowerCase().contains(query) ||
              song.artist.toLowerCase().contains(query) ||
              song.album.toLowerCase().contains(query);
        }).toList();
      } else if (selectedTabIndex == 1) {
        filteredAlbums = widget.allSongs
            .map((song) => song.album)
            .where((album) => album.toLowerCase().contains(query))
            .toSet()
            .toList();
      } else if (selectedTabIndex == 2) {
        filteredArtists = widget.artistImageMap.entries
            .where((entry) => entry.key.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void onTabChanged(int index) {
    FocusScope.of(context).unfocus(); // dismiss cursor
    setState(() {
      selectedTabIndex = index;
      updateSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          widget.onBackToHome();
          return false;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
          child: Stack(
            children: [
              Column(
                children: [
                  /// 🔍 Search Bar
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: widget.onBackToHome,
                        ),
                        Expanded(
                          child: TextField(
                            autofocus: false,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Search songs, artists, albums',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            onChanged: updateSearch,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 🗂 Tabs
                  Container(
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _tabButton("Songs", 0),
                        _tabButton("Albums", 1),
                        _tabButton("Artists", 2),
                      ],
                    ),
                  ),

                  /// 📋 Content
                  Expanded(
                    child: selectedTabIndex == 0
                        ? buildSongsList()
                        : selectedTabIndex == 1
                            ? FullAlbumGridSection(
                                albums: filteredAlbums.map((albumTitle) {
                                  return Album(
                                    title: albumTitle,
                                    image: widget.allSongs.firstWhere((s) => s.album == albumTitle).image,
                                    songs: widget.allSongs.where((s) => s.album == albumTitle).toList(),
                                  );
                                }).toList(),
                              )
                            : ArtistListSection(
                                allSongs: widget.allSongs,
                                artistImageMap: Map.fromEntries(filteredArtists),
                              ),
                  ),
                ],
              ),

              /// 🎵 Mini Player
              const Positioned(left: 0, right: 0, bottom: 0, child: MiniPlayer()),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎶 Songs Tab List
  Widget buildSongsList() {
    if (filteredSongs.isEmpty) {
      return const Center(
        child: Text("No songs found", style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      itemCount: filteredSongs.length,
      padding: const EdgeInsets.only(bottom: 90),
      itemBuilder: (context, index) {
        final song = filteredSongs[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              song.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            '${song.artist} • ${song.album}',
            style: const TextStyle(color: Colors.white70),
          ),
          onTap: () async {
            FocusScope.of(context).unfocus(); // dismiss keyboard before navigating
            await PlayerManager().playSong(song, filteredSongs);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerPage(
                  song: song,
                  playlist: filteredSongs,
                  album: song.album,
                ),
              ),
            );
          },
          trailing: SongOptionsPopup(song: song, playlist: filteredSongs),
        );
      },
    );
  }

  /// 🏷 Tab Button Widget
  Widget _tabButton(String label, int index) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
