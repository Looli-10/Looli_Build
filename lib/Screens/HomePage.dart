import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/song_service.dart';
import 'package:looli_app/widgets/AlbumGridSection.dart';
import 'package:looli_app/widgets/ArtistSection.dart';
import 'package:looli_app/widgets/LanguageSectionGrid.dart';
import 'package:looli_app/widgets/Recently_played_section.dart';
import 'package:looli_app/widgets/ThemeAlbumCard.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/widgets/LatestReleaseCard.dart';

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

  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoad();
  }

  Future<void> _checkConnectivityAndLoad() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isOffline = true;
      });
    } else {
      setState(() {
        isOffline = false;
        final songService = SongService();
        _albumsFuture = songService.fetchAlbumsFromGitHub();
        _songsFuture = songService.fetchSongsFromGitHub();
        _themeImagesFuture = songService.fetchThemeImageMap();
        _artistImagesFuture = songService.fetchArtistImageMap();
        _languageColorMapFuture = songService.fetchLanguageColorMap();
      });
    }
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
        backgroundColor: Colors.black26,
        body: isOffline
            ? _buildOfflineScreen()
            : FutureBuilder(
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
                    return _buildOfflineScreen(error: snapshot.error.toString());
                  }

                  final albums = snapshot.data![0] as List<Album>;
                  final songs = snapshot.data![1] as List<Song>;
                  final themeImages = snapshot.data![2] as Map<String, String>;
                  final artistImages = snapshot.data![3] as Map<String, String>;
                  final languageColorMap = snapshot.data![4] as Map<String, String>;

                  final latestAlbum = albums.first;
                  final randomAlbums = List<Album>.from(albums)..removeAt(0);
                  randomAlbums.shuffle();
                  final gridAlbums = randomAlbums.take(4).toList();

                  return Stack(
                    children: [
                      ListView(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.5,
                                  fontFamily: 'Kola',
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Lo',
                                    style: TextStyle(
                                      color: looliFourth,
                                      fontFamily: 'Kola',
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'oli',
                                    style: TextStyle(
                                      color: looliFirst,
                                      fontFamily: 'Kola',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          RecentlyPlayedSection(
                            allAlbums: albums,
                            song: songs.first,
                          ),
                          const SizedBox(height: 10),
                          LatestReleaseCard(album: latestAlbum),
                          const SizedBox(height: 15),
                          AlbumsGridSection(albums: gridAlbums, song: songs),
                          const SizedBox(height: 30),
                          ArtistAlbumCardSection(
                            allSongs: songs,
                            artistImageMap: artistImages,
                          ),
                          const SizedBox(height: 30),
                          ThemeAlbumCardSection(
                            allSongs: songs,
                            themeImageMap: themeImages,
                          ),
                          const SizedBox(height: 30),
                          LanguageSectionGrid(
                            allSongs: songs,
                            languageColorMap: languageColorMap,
                          ),
                        ],
                      ),
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

  Widget _buildOfflineScreen({String? error}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 60),
            const SizedBox(height: 20),
            const Text(
              "You're Offline",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkConnectivityAndLoad();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
