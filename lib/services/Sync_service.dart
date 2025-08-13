import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../Models/songs.dart';
import '../Models/playlist.dart';

class SyncService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> initSync(String userId) async {
    // Merge Firestore data into Hive local storage on login
    await syncSongs(userId);
    await syncPlaylists(userId);

    // Start watching Hive local changes and push to Firestore
    _startWatchingSongs(userId);
    _startWatchingPlaylists(userId);
  }

  Future<void> syncSongs(String userId) async {
    final songBox = Hive.box<Song>('liked_songs');

    final firestoreSongsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('songs')
        .get();

    final firestoreSongs = firestoreSongsSnap.docs.map((doc) {
      return Song.fromJson(doc.data());
    }).toList();

    final localSongs = songBox.values.toList();
    final mergedSongs = _mergeById<Song>(localSongs, firestoreSongs, (song) => song.id);

    await songBox.clear();
    await songBox.putAll({for (var s in mergedSongs) s.id: s});

    for (var song in mergedSongs) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('songs')
          .doc(song.id)
          .set(song.toJson(), SetOptions(merge: true));
    }
  }

  Future<void> syncPlaylists(String userId) async {
    final playlistBox = Hive.box<Playlist>('custom_playlists');

    final firestorePlaylistsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .get();

    final firestorePlaylists = firestorePlaylistsSnap.docs.map((doc) {
      return Playlist.fromJson(doc.data());
    }).toList();

    final localPlaylists = playlistBox.values.toList();
    final mergedPlaylists =
        _mergeById<Playlist>(localPlaylists, firestorePlaylists, (playlist) => playlist.id);

    await playlistBox.clear();
    await playlistBox.putAll({for (var p in mergedPlaylists) p.id: p});

    for (var playlist in mergedPlaylists) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlist.id)
          .set(playlist.toJson(), SetOptions(merge: true));
    }
  }

  void _startWatchingSongs(String userId) {
    final songBox = Hive.box<Song>('liked_songs');
    songBox.watch().listen((event) async {
      final song = songBox.get(event.key);
      if (song != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('songs')
            .doc(song.id)
            .set(song.toJson(), SetOptions(merge: true));
      } else {
        // Deleted song: remove from Firestore as well
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('songs')
            .doc(event.key)
            .delete();
      }
    });
  }

  void _startWatchingPlaylists(String userId) {
    final playlistBox = Hive.box<Playlist>('custom_playlists');
    playlistBox.watch().listen((event) async {
      final playlist = playlistBox.get(event.key);
      if (playlist != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('playlists')
            .doc(playlist.id)
            .set(playlist.toJson(), SetOptions(merge: true));
      } else {
        // Deleted playlist: remove from Firestore as well
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('playlists')
            .doc(event.key)
            .delete();
      }
    });
  }

  List<T> _mergeById<T>(
    List<T> local,
    List<T> remote,
    String Function(T) getId,
  ) {
    final Map<String, T> mergedMap = {};

    for (var item in local) {
      mergedMap[getId(item)] = item;
    }

    for (var item in remote) {
      mergedMap.putIfAbsent(getId(item), () => item);
    }

    return mergedMap.values.toList();
  }
}
