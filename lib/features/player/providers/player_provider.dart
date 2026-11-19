import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> _queue = [];

  SongModel? current;
  bool isPlaying = false;
  bool shuffle = false;
  LoopMode loopMode = LoopMode.off;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  PlayerProvider() {
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _queue.length) {
        current = _queue[index];
        notifyListeners();
      }
    });
  }

  AudioSource _source(SongModel s) {
    final uri = s.uri;
    return AudioSource.uri(uri != null ? Uri.parse(uri) : Uri.file(s.data));
  }

  Future<void> playQueue(List<SongModel> songs, int index) async {
    _queue = songs;
    current = songs[index];
    notifyListeners();
    try {
      await _player.setAudioSources(
        songs.map(_source).toList(),
        initialIndex: index,
      );
      await _player.play();
    } catch (e) {
      debugPrint('error al reproducir: $e');
    }
  }

  void togglePlay() => isPlaying ? _player.pause() : _player.play();
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> toggleShuffle() async {
    shuffle = !shuffle;
    await _player.setShuffleModeEnabled(shuffle);
    notifyListeners();
  }

  Future<void> cycleLoop() async {
    loopMode = switch (loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(loopMode);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}