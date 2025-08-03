import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/ThemeSongsPage.dart';

class ThemeAlbumCardSection extends StatelessWidget {
  final List<Song> allSongs;
  final Map<String, String> themeImageMap; 

  const ThemeAlbumCardSection({
    super.key,
    required this.allSongs,
    required this.themeImageMap,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Song>> themeGroups = {};

    for (var song in allSongs) {
      final theme = song.theme?.toLowerCase().trim();
      if (theme == null || theme.isEmpty) continue;
      themeGroups.putIfAbsent(theme, () => []).add(song);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "How’s your mood?",
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
            children: themeGroups.entries.map((entry) {
              final theme = entry.key;
              final themeSongs = entry.value;
              final image = themeImageMap[theme] ??
                  themeImageMap['default'] ??
                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_960_720.jpg';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThemeSongsPage(
                        themeTitle: theme[0].toUpperCase() + theme.substring(1),
                        songs: themeSongs,
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
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        theme[0].toUpperCase() + theme.substring(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
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
