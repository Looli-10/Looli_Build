import 'dart:async';
import 'package:flutter/material.dart';
import 'package:looli_app/Constants/Colors/app_colors.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/HomePage.dart';
import 'package:looli_app/Screens/SearchPage.dart';
import 'package:looli_app/Screens/LibraryPage.dart';
import 'package:looli_app/services/song_service.dart';
import 'package:looli_app/services/connectivity_service.dart';
import 'package:looli_app/widgets/Bottom_nav.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  Future<List<Song>>? _songsFuture;
  Future<Map<String, String>>? _artistImagesFuture;

  late ConnectivityService _connectivityService;
  late StreamSubscription<bool> _connectivitySubscription;
  bool _isConnected = true;

  late List<Song> allSongs;
  late Map<String, String> artistImageMap;

  bool _dataFetched = false; // Track if search data is fetched

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();

    _connectivitySubscription =
        _connectivityService.connectivityStream.listen((connected) {
      if (!connected && _isConnected != false) {
        _showOfflineSnackbar();
      }

      // If just came back online and data isn't fetched yet
      if (connected && !_isConnected && !_dataFetched) {
        _fetchSearchData();
      }

      setState(() {
        _isConnected = connected;
      });
    });

    _initializeConnection();
    _fetchSearchData(); // 🔹 Fetch immediately so BottomNav is ready
  }

  Future<void> _initializeConnection() async {
    final connected = await _connectivityService.checkConnection();
    setState(() {
      _isConnected = connected;
    });
  }

  Future<void> _fetchSearchData() async {
    if (!_isConnected) return;

    final songService = SongService();
    setState(() {
      _songsFuture = songService.fetchSongsFromGitHub();
      _artistImagesFuture = songService.fetchArtistImageMap();
    });
    _dataFetched = true;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _showOfflineSnackbar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('You are offline. Some features may not work.'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildSearchTab() {
    return FutureBuilder<List<Song>>(
      future: _songsFuture,
      builder: (context, songSnapshot) {
        if (songSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        } else if (songSnapshot.hasError) {
          return Center(
            child: Text(
              "Error loading songs: ${songSnapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        allSongs = songSnapshot.data ?? [];

        return FutureBuilder<Map<String, String>>(
          future: _artistImagesFuture,
          builder: (context, artistSnapshot) {
            if (artistSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            } else if (artistSnapshot.hasError) {
              return Center(
                child: Text(
                  "Error loading artist images: ${artistSnapshot.error}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            artistImageMap = artistSnapshot.data ?? {};

            return SearchPage(
              allSongs: allSongs,
              artistImageMap: artistImageMap,
              onBackToHome: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: looliThird,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const Homepage(),
          _isConnected
              ? _buildSearchTab()
              : const Center(
                  child: Text(
                    "You're offline.\nPlease connect to load songs.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
          const LibraryPage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
