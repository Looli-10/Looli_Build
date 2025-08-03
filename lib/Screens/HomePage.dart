import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/song_service.dart';
import 'package:looli_app/widgets/AlbumGridSection.dart';
import 'package:looli_app/widgets/ArtistSection.dart';
import 'package:looli_app/widgets/LanguageSectionGrid.dart';
import 'package:looli_app/widgets/ThemeAlbumCard.dart';
import 'package:looli_app/widgets/mini_player.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<List<Album>> _albumsFuture;
  late Future<List<Song>> _songsFuture;
  late Future<Map<String, String>> _themeImagesFuture;
  late Future<Map<String, String>> _artistImagesFuture;
  late Future<Map<String, String>> _languageColorMapFuture;

  
  get languageColorMap => null;

  @override
  void initState() {
    super.initState();
    final songService = SongService();
    _albumsFuture = songService.fetchAlbumsFromGitHub();
    _songsFuture = songService.fetchSongsFromGitHub();
    _themeImagesFuture = songService.fetchThemeImageMap();
    _artistImagesFuture = songService.fetchArtistImageMap();
    _languageColorMapFuture = songService.fetchLanguageColorMap();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Looli',
            style: TextStyle(
              color: looliFourth,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: 'Poppins',
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: Future.wait([
            _albumsFuture,
            _songsFuture,
            _themeImagesFuture,
            _artistImagesFuture,
            _languageColorMapFuture,
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final albums = snapshot.data![0] as List<Album>;
            final songs = snapshot.data![1] as List<Song>;
            final themeImages = snapshot.data![2] as Map<String, String>;
            final artistImages = snapshot.data![3] as Map<String, String>;
            final languageColorMap = snapshot.data![4] as Map<String, String>;
            

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 90),
                  children: [
                    const SizedBox(height: 20),

                    /// 🔹 Albums Section
                    AlbumsGridSection(albums: albums),
                    const SizedBox(height: 30),

                    /// 🔹 Theme Section with dynamic image map
                    ThemeAlbumCardSection(
                      allSongs: songs,
                      themeImageMap: themeImages,
                    ),
                    const SizedBox(height: 30),

                    /// 🔹 Artist Section with artist image map
                    ArtistAlbumCardSection(
                      allSongs: songs,
                      artistImageMap: artistImages,
                    ),
                    const SizedBox(height: 30),

                    /// 🔹 Language Section (NEW)
                    LanguageSectionGrid(
                      allSongs: songs,
                      languageColorMap: languageColorMap, 
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
                /// 🔹 Mini Player
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MiniPlayer(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
