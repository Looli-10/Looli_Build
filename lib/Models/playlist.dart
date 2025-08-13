import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'songs.dart';

part 'playlist.g.dart';

@HiveType(typeId: 2)
class Playlist extends HiveObject {
  @HiveField(0)
  String id; // Unique ID

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Song> songs;

  // Firebase Storage URL
  @HiveField(3)
  String? imageUrl;

  Playlist({
    String? id,
    required this.name,
    required this.songs,
    this.imageUrl,
  }) : id = id ?? const Uuid().v4();

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'] ?? '',
      songs: (json['songs'] as List<dynamic>? ?? [])
          .map((songJson) => Song.fromJson(Map<String, dynamic>.from(songJson)))
          .toList(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((s) => s.toJson()).toList(),
      'imageUrl': imageUrl,
    };
  }
}
