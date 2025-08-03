import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:looli_app/Models/songs.dart';
import 'package:looli_app/services/queue_service.dart';
import 'package:audio_service/audio_service.dart';

class PlayerManager {
  static final PlayerManager _instance = PlayerManager._internal();
  factory PlayerManager() => _instance;

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<Song?> currentSongNotifier = ValueNotifier(null);
  final ValueNotifier<LoopMode> repeatModeNotifier = ValueNotifier(LoopMode.off);
  final ValueNotifier<bool> shuffleModeNotifier = ValueNotifier(false);

  List<Song> _playlist = [];
  List<Song> _queue = [];
  bool _isQueueActive = false;

  ConcatenatingAudioSource? _audioSource;

  PlayerManager._internal() {
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _playlist.length) {
        currentSongNotifier.value = _playlist[index];
      }
    });

    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        if (_isQueueActive && !_player.hasNext) {
          _isQueueActive = false;
          await _resumeAlbum();
        }
      }
    });
  }

  AudioPlayer get player => _player;
  List<Song> get currentPlaylist => _playlist;
  set currentPlaylist(List<Song> playlist) {
    _playlist = playlist;
  }

  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;

    _audioSource = ConcatenatingAudioSource(
      children: songs.map((s) {
        return AudioSource.uri(
          Uri.parse(s.url),
          tag: MediaItem(
            id: s.id.toString(),
            title: s.title,
            artist: s.artist,
            album: s.album,
            artUri: Uri.tryParse(s.image),
          ),
        );
      }).toList(),
    );

    await _player.stop();
    await _player.setAudioSource(_audioSource!, initialIndex: startIndex);
    await _player.play();
    _isQueueActive = false;
  }

  Future<void> playSong(Song song, List<Song> playlist) async {
    final index = playlist.indexWhere((s) => s.id == song.id);
    if (index == -1) return;
    await setPlaylist(playlist, startIndex: index);
  }

  Future<void> playQueue(List<Song> queue) async {
    if (queue.isEmpty) return;
    _isQueueActive = true;
    _queue = queue;
    await playSong(queue.first, queue);
  }

  Future<void> appendToQueue(List<Song> newSongs) async {
    if (_audioSource == null || _playlist.isEmpty) return;

    final newSources = newSongs.map((s) {
      return AudioSource.uri(
        Uri.parse(s.url),
        tag: MediaItem(
          id: s.id.toString(),
          title: s.title,
          artist: s.artist,
          album: s.album,
          artUri: Uri.tryParse(s.image),
        ),
      );
    }).toList();

    final currentIndex = _player.currentIndex ?? 0;
    final insertIndex = currentIndex + 1;

    _playlist.insertAll(insertIndex, newSongs);

    final concatSource = _audioSource as ConcatenatingAudioSource;
    await concatSource.insertAll(insertIndex, newSources);
  }

  Future<void> resumeQueueIfExists() async {
    final queue = await QueueService().getQueue();
    if (queue.isNotEmpty) {
      await playQueue(queue);
    }
  }

  Future<void> _resumeAlbum() async {
    if (_playlist.isEmpty) return;
    final current = currentSongNotifier.value;
    final index = _playlist.indexWhere((s) => s.id == current?.id);
    final nextIndex = index + 1;
    if (nextIndex < _playlist.length) {
      await setPlaylist(_playlist, startIndex: nextIndex);
    }
  }

  void toggleShuffle() async {
    final enabled = !shuffleModeNotifier.value;
    shuffleModeNotifier.value = enabled;
    await _player.setShuffleModeEnabled(enabled);
  }

  void toggleRepeat() {
    LoopMode next;
    switch (_player.loopMode) {
      case LoopMode.off:
        next = LoopMode.all;
        break;
      case LoopMode.all:
        next = LoopMode.one;
        break;
      case LoopMode.one:
        next = LoopMode.off;
        break;
    }
    _player.setLoopMode(next);
    repeatModeNotifier.value = next;
  }

  void playNext() => _player.seekToNext();
  void playPrevious() => _player.seekToPrevious();

  Future<void> stop() async {
    await _player.stop();
    currentSongNotifier.value = null;
  }

  Future<void> setSong(Song song, List<Song> playlist) async {
    currentPlaylist = playlist;
    currentSongNotifier.value = song;

    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(song.url),
        tag: MediaItem(
          id: song.id.toString(),
          title: song.title,
          artist: song.artist,
          album: song.album,
          artUri: Uri.tryParse(song.image),
        ),
      ),
    );
  }
}
