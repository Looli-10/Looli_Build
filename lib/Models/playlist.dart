import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'songs.dart';

part 'playlist.g.dart';

@HiveType(typeId: 2)
class Playlist extends HiveObject {
  @HiveField(0)
  String id; // 🎯 Unique ID for sync

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Song> songs;

  @HiveField(3)
  String? imagePath;

  Playlist({
    String? id,
    required this.name,
    required this.songs,
    this.imagePath,
  }) : id = id ?? const Uuid().v4(); // auto-generate if not provided

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'] ?? '',
      songs: (json['songs'] as List<dynamic>? ?? [])
          .map((songJson) => Song.fromJson(Map<String, dynamic>.from(songJson)))
          .toList(),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((s) => s.toJson()).toList(),
      'imagePath': imagePath,
    };
  }
}
