import 'package:flutter/material.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/Screens/AlbumSongsPage.dart';

class AlbumsGridSection extends StatelessWidget {
  final List<Album> albums;

  const AlbumsGridSection({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    final limitedAlbums = albums.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        itemCount: limitedAlbums.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 2.7, // Wider card look
        ),
        itemBuilder: (context, index) {
          final album = limitedAlbums[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => AlbumSongsPage(
                        albumTitle: album.title,
                        songs: album.songs,
                      ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2E2C2F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  // Album Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                    child: Image.network(
                      album.image,
                      width: 70,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Album Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${album.songs.length} Songs',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
