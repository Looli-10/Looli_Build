import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:looli_app/AuthScreens/RegOrLogin.dart';
import 'package:looli_app/Models/playlist.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/Sync_service.dart';
import 'package:looli_app/services/playlist_service.dart';
import 'package:looli_app/widgets/audio_manager.dart';
import 'package:looli_app/services/MainNavigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  Hive.registerAdapter(SongAdapter());
  await Hive.openBox<Song>('queue_songs');
  await Hive.openBox('player_state');
  await Hive.openBox<Song>('liked_songs');

  Hive.registerAdapter(PlaylistAdapter());
  await Hive.openBox<Playlist>('custom_playlists');
  await PlaylistService.init();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.looli_app.channel.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
  );

  await PlayerManager().restoreLastPlayedSong();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _removeSplash();
  }

  void _removeSplash() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      PlayerManager().stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Looli',
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // While checking auth state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // If user is logged in
              if (snapshot.hasData) {
                final userId = snapshot.data!.uid;
                SyncService().initSync(userId);
                return MainNavigation();
              }
              // If user is not logged in
              return const LoginPage(); // Or RegOrLogin
            },
          ),
        );
      },
    );
  }
}
