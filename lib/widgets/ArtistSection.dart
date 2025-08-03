import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/ArtistSongsPage.dart';

class ArtistAlbumCardSection extends StatelessWidget {
  final List<Song> allSongs;
  final Map<String, String> artistImageMap;

  const ArtistAlbumCardSection({
    super.key,
    required this.allSongs,
    required this.artistImageMap,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Song>> artistGroups = {};

    for (var artistKey in artistImageMap.keys) {
      final matchedSongs =
          allSongs.where((song) {
            final songArtists =
                song.artist
                    .split(',')
                    .map((s) => s.trim().toLowerCase())
                    .toList();

            return songArtists.contains(artistKey.toLowerCase());
          }).toList();

      if (matchedSongs.isNotEmpty) {
        artistGroups[artistKey] = matchedSongs;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "Artists",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children:
                artistGroups.entries.map((entry) {
                  final artist = entry.key;
                  final artistSongs = entry.value;
                  final image = artistImageMap[artist]!;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ArtistSongsPage(
                                artist: artist,
                                songs: artistSongs,
                                artistImage: image,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            artist,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              shadows: [
                                Shadow(blurRadius: 2, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}