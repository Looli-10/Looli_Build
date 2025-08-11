import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../Models/songs.dart';
import '../Models/playlist.dart';

class SyncService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> syncSongs(String userId) async {
    final songBox = Hive.box<Song>('liked_songs');

    // Pull from Firestore
    final firestoreSongsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('songs')
        .get();

    final firestoreSongs = firestoreSongsSnap.docs.map((doc) {
      return Song.fromJson(doc.data());
    }).toList();

    // Merge
    final localSongs = songBox.values.toList();
    final mergedSongs = _mergeById<Song>(
      localSongs,
      firestoreSongs,
      (song) => song.id,
    );

    // Save merged to Hive
    await songBox.clear();
    await songBox.addAll(mergedSongs);

    // Push merged to Firestore
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

    // Pull from Firestore
    final firestorePlaylistsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('playlists')
        .get();

    final firestorePlaylists = firestorePlaylistsSnap.docs.map((doc) {
      return Playlist.fromJson(doc.data());
    }).toList();

    // Merge
    final localPlaylists = playlistBox.values.toList();
    final mergedPlaylists = _mergeById<Playlist>(
      localPlaylists,
      firestorePlaylists,
      (playlist) => playlist.id,
    );

    // Save merged to Hive
    await playlistBox.clear();
    await playlistBox.addAll(mergedPlaylists);

    // Push merged to Firestore
    for (var playlist in mergedPlaylists) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists')
          .doc(playlist.id)
          .set(playlist.toJson(), SetOptions(merge: true));
    }
  }

  // Generic merge by ID
  List<T> _mergeById<T>(
    List<T> local,
    List<T> remote,
    String Function(T) getId,
  ) {
    final Map<String, T> mergedMap = {};

    // Add local
    for (var item in local) {
      mergedMap[getId(item)] = item;
    }

    // Add remote (overwrites only if not present locally)
    for (var item in remote) {
      mergedMap.putIfAbsent(getId(item), () => item);
    }

    return mergedMap.values.toList();
  }
}
