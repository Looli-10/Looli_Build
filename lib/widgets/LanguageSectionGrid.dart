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

    final limitedLanguages = languageGroups.entries.take(6).toList();

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
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: limitedLanguages.length,
            itemBuilder: (context, index) {
              final entry = limitedLanguages[index];
              final lang = entry.key;
              final color = hexToColor(languageColorMap[lang]!);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LanguageAlbumsPage(
                        language: lang,
                        songs: entry.value,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          lang,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
            },
          ),
        ),
      ],
    );
  }
}
