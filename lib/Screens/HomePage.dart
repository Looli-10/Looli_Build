import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:looli_app/AuthScreens/RegOrLogin.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/playlist.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/playlist_service.dart';
import 'package:looli_app/services/song_service.dart';
import 'package:looli_app/widgets/AlbumGridSection.dart';
import 'package:looli_app/widgets/ArtistSection.dart';
import 'package:looli_app/widgets/LanguageSectionGrid.dart';
import 'package:looli_app/widgets/Recently_played_section.dart';
import 'package:looli_app/widgets/ThemeAlbumCard.dart';
import 'package:looli_app/widgets/mini_player.dart';
import 'package:looli_app/widgets/LatestReleaseCard.dart';
import 'package:looli_app/Screens/PlaylistDetailPage.dart';
import 'package:looli_app/widgets/sidebar_drawer.dart';

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
  List<Playlist> _playlists = [];
  final User? _user = FirebaseAuth.instance.currentUser;

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
      isOffline = false;
      final songService = SongService();
      _albumsFuture = songService.fetchAlbumsFromGitHub();
      _songsFuture = songService.fetchSongsFromGitHub();
      _themeImagesFuture = songService.fetchThemeImageMap();
      _artistImagesFuture = songService.fetchArtistImageMap();
      _languageColorMapFuture = songService.fetchLanguageColorMap();
      _playlists = await PlaylistService.getAllPlaylists();
      setState(() {}); // Trigger UI update after loading
    }
  }

  Future<void> _refreshPlaylists() async {
    final updatedPlaylists = await PlaylistService.getAllPlaylists();
    setState(() {
      _playlists = updatedPlaylists;
    });
  }

  // Widget _buildSidebar() {
  //   return Drawer(
  //     backgroundColor: Colors.black,
  //     child: Column(
  //       children: [
  //         const SizedBox(height: 60),
  //         CircleAvatar(
  //           radius: 40,
  //           backgroundImage:
  //               _user?.photoURL != null
  //                   ? NetworkImage(_user!.photoURL!)
  //                   : const AssetImage('assets/images/default_profile.png')
  //                       as ImageProvider,
  //         ),
  //         const SizedBox(height: 10),
  //         Text(
  //           _user?.displayName ?? "Looli User",
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             fontFamily: 'Poppins',
  //           ),
  //         ),
  //         const SizedBox(height: 5),
  //         Text(
  //           _user?.email ?? "",
  //           style: const TextStyle(
  //             color: Colors.grey,
  //             fontSize: 14,
  //             fontFamily: 'Poppins',
  //           ),
  //         ),
  //         const Spacer(),
  //         ListTile(
  //           leading: const Icon(Icons.logout, color: Colors.white),
  //           title: const Text('Logout', style: TextStyle(color: Colors.white)),
  //           onTap: () async {
  //             await FirebaseAuth.instance.signOut();
  //             // After logout, rebuild the UI and go to login screen
  //             if (mounted) {
  //               Navigator.of(context).pushReplacement(
  //                 MaterialPageRoute(builder: (_) => const LoginPage()),
  //               );
  //             }
  //           },
  //         ),
  //         const SizedBox(height: 20),
  //       ],
  //     ),
  //   );
  // }

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
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false,
    centerTitle: true,
    title: RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5,
          fontFamily: 'Kola',
        ),
        children: [
          TextSpan(text: 'Lo', style: TextStyle(color: looliFourth)),
          TextSpan(text: 'oli', style: TextStyle(color: looliFirst)),
        ],
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Builder(
          builder: (context) {
            final userBox = Hive.box('userBox');
            return ValueListenableBuilder(
              valueListenable: userBox.listenable(),
              builder: (context, box, _) {
                final customImage = box.get('customImage');
                final user = _user; // from your state

                ImageProvider avatarImage = const AssetImage('assets/images/profile-user.png');

                if (customImage != null) {
                  avatarImage = MemoryImage(customImage);
                } else if (user?.photoURL != null) {
                  avatarImage = NetworkImage(user!.photoURL!);
                }

                return GestureDetector(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    backgroundImage: avatarImage,
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
  ),

  endDrawer: SidebarDrawer(user: _user),

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
              return _buildOfflineScreen(
                error: snapshot.error.toString(),
              );
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
                    RecentlyPlayedSection(allAlbums: albums, song: songs.first),
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
                    _buildPlaylistSection(),
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

  /// Playlist Section UI matching ArtistCard style
  Widget _buildPlaylistSection() {
    if (_playlists.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "Your Playlists",
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
            itemCount: _playlists.length,
            itemBuilder: (context, index) {
              final playlist = _playlists[index];
              return GestureDetector(
                onTap: () {
                  final result = Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailPage(playlist: playlist),
                    ),
                  );
                  if (result == true) {
                    _refreshPlaylists();
                  }
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    image:
                        playlist.imagePath != null
                            ? DecorationImage(
                              image: FileImage(File(playlist.imagePath!)),
                              fit: BoxFit.cover,
                            )
                            : const DecorationImage(
                              image: AssetImage(
                                "assets/images/profile-user.png",
                              ), // fallback
                              fit: BoxFit.cover,
                            ),
                    borderRadius: BorderRadius.circular(7),
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
                            borderRadius: BorderRadius.circular(7),
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
                      Positioned(
                        left: 10,
                        bottom: 10,
                        right: 10,
                        child: Text(
                          playlist.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
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
              onPressed: _checkConnectivityAndLoad,
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

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }
}
