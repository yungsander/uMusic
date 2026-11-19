import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> _queue = [];
  int _loadId = 0;
  bool _loading = false;

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
      // Durante la carga se ignoran los cambios de índice intermedios
      if (_loading) return;
      if (index == null || index >= _queue.length) return;
      // Descarta eventos atrasados que ya no coinciden con el reproductor
      if (index != _player.currentIndex) return;
      current = _queue[index];
      notifyListeners();
    });

    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        debugPrint('Error del reproductor: $e');
      },
    );
  }

  AudioSource _source(SongModel s) {
    final uri = s.uri;
    return AudioSource.uri(uri != null ? Uri.parse(uri) : Uri.file(s.data));
  }

  Future<void> playQueue(List<SongModel> songs, int index) async {
    final id = ++_loadId;
    _loading = true;
    _queue = songs;
    current = songs[index];
    notifyListeners();
    try {
      await _player.setAudioSources(
        songs.map(_source).toList(),
        initialIndex: index,
      );
      if (id != _loadId) return;
      current = songs[index];
      _loading = false;
      notifyListeners();

      _player.play().catchError((Object e) {
        debugPrint('Error al reproducir: $e');
      });
    } on PlayerInterruptedException {
      // Empezó otra carga: se ignora
    } catch (e) {
      debugPrint('Error al reproducir: $e');
    } finally {
      if (id == _loadId) _loading = false;
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