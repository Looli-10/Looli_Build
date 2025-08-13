import 'package:hive/hive.dart';
import 'package:looli_app/Models/playlist.dart';
import 'package:looli_app/Models/songs.dart';

class PlaylistService {
  static const String _boxName = 'custom_playlists';

  static Future<void> init() async {
    await Hive.openBox<Playlist>(_boxName);
  }

  static List<Playlist> getAllPlaylists() {
    final box = Hive.box<Playlist>(_boxName);
    return box.values.toList();
  }

  static Future<void> addPlaylist(Playlist playlist) async {
    final box = Hive.box<Playlist>(_boxName);
    await box.put(playlist.id, playlist);  // Use id as key
  }

  static Future<void> updatePlaylistById(String id, Playlist updatedPlaylist) async {
    final box = Hive.box<Playlist>(_boxName);
    await box.put(id, updatedPlaylist);
  }

  static Future<void> deletePlaylistById(String id) async {
    final box = Hive.box<Playlist>(_boxName);
    await box.delete(id);
  }

  static Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final box = Hive.box<Playlist>(_boxName);
    final playlist = box.get(playlistId);
    if (playlist != null && !playlist.songs.any((s) => s.id == song.id)) {
      playlist.songs.add(song);
      await playlist.save();
    }
  }

  static Future<void> removeSongFromPlaylist(String playlistId, Song song) async {
    final box = Hive.box<Playlist>(_boxName);
    final playlist = box.get(playlistId);
    if (playlist != null) {
      playlist.songs.removeWhere((s) => s.id == song.id);
      await playlist.save();
    }
  }

  static Box<Playlist> getBox() {
    return Hive.box<Playlist>(_boxName);
  }
}
