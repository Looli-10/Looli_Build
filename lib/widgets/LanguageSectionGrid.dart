import 'package:flutter/material.dart';
import 'package:looli_app/Constants/helper/color_utils.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/LanguageAlbumsPage.dart';

class LanguageSectionGrid extends StatelessWidget {
  final List<Song> allSongs;
  final Map<String, String> languageColorMap;

  const LanguageSectionGrid({
    super.key,
    required this.allSongs,
    required this.languageColorMap,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Song>> languageGroups = {};

    for (var lang in languageColorMap.keys) {
      final matchedSongs = allSongs
          .where((song) => song.language.toLowerCase() == lang.toLowerCase())
          .toList();

      if (matchedSongs.isNotEmpty) {
        languageGroups[lang] = matchedSongs;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "Languages",
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
            children: languageGroups.entries.map((entry) {
              final lang = entry.key;
              final color = hexToColor(languageColorMap[lang]!);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LanguageAlbumsPage(language: lang, songs: allSongs),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Container(
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
                      ),
                      Center(
                        child: Text(
                          lang,
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
                    ],
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
