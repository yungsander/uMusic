import 'dart:math';
import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../core/utils/song_utils.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player;
  final Random _random = Random();

  List<SongModel> _queue = [];
  List<SongModel> _original = [];
  int _loadId = 0;
  bool _loading = false; // cargando una cola nueva
  bool _busy = false; // editando la cola (mover, quitar, mezclar)

  SongModel? current;
  bool isPlaying = false;
  bool shuffle = false;
  LoopMode loopMode = LoopMode.off;

  List<SongModel> get queue => _queue;
  int get currentQueueIndex => _queue.indexWhere((s) => s.id == current?.id);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  PlayerProvider(this._player) {
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });

    _player.currentIndexStream.listen((index) {
      // Durante cargas o ediciones se ignoran los índices intermedios
      if (_loading || _busy) return;
      if (index == null || index >= _queue.length) return;
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

  MediaItem _mediaItem(SongModel s) {
    final dur = s.duration;
    final album = s.album;
    return MediaItem(
      id: s.id.toString(),
      title: s.title,
      artist: s.artistName,
      album: (album == null || album == '<unknown>') ? null : album,
      duration: (dur != null && dur > 0) ? Duration(milliseconds: dur) : null,
      artUri: s.albumId != null
          ? Uri.parse('content://media/external/audio/albumart/${s.albumId}')
          : null,
    );
  }

  AudioSource _source(SongModel s) {
    final uri = s.uri;
    return AudioSource.uri(
      uri != null ? Uri.parse(uri) : Uri.file(s.data),
      tag: _mediaItem(s),
    );
  }

  Future<void> playQueue(List<SongModel> songs, int index) async {
    final id = ++_loadId;
    _loading = true;

    List<SongModel> order;
    int startIndex;
    if (shuffle) {
      // La canción elegida va primero; el resto se mezcla
      _original = List.of(songs);
      final rest = List.of(songs)..removeAt(index);
      rest.shuffle(_random);
      order = [songs[index], ...rest];
      startIndex = 0;
    } else {
      _original = [];
      order = List.of(songs);
      startIndex = index;
    }

    _queue = order;
    current = order[startIndex];
    notifyListeners();

    try {
      await _player.setAudioSources(
        order.map(_source).toList(),
        initialIndex: startIndex,
      );
      if (id != _loadId) return;
      current = order[startIndex];
      _loading = false;
      notifyListeners();

      // Sin await: play() solo termina cuando la reproducción se pausa o acaba
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

  Future<void> playShuffled(List<SongModel> songs) async {
    if (songs.isEmpty) return;
    shuffle = true;
    await playQueue(songs, _random.nextInt(songs.length));
  }

  void togglePlay() => isPlaying ? _player.pause() : _player.play();
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();
  Future<void> seek(Duration position) => _player.seek(position);

  // ---------- Aleatorio ----------

  Future<void> toggleShuffle() async {
    shuffle = !shuffle;
    notifyListeners();
    if (_queue.length < 2) return;

    final i = _player.currentIndex;
    if (i == null) return;
    final oldLength = _queue.length;

    _busy = true;
    try {
      if (shuffle) {
        _original = List.of(_queue);
        final after = _queue.sublist(i + 1)..shuffle(_random);
        _queue = [..._queue.sublist(0, i + 1), ...after];
        notifyListeners();
        if (after.isNotEmpty) {
          await _player.removeAudioSourceRange(i + 1, oldLength);
          await _player.addAudioSources(after.map(_source).toList());
        }
      } else {
        // Restaura el orden original, conservando solo lo que sigue en la cola
        final present = _queue.map((s) => s.id).toSet();
        final restored =
            _original.where((s) => present.contains(s.id)).toList();
        final k = restored.indexWhere((s) => s.id == current?.id);
        if (k < 0) return;
        final before = restored.sublist(0, k);
        final after = restored.sublist(k + 1);
        _queue = restored;
        notifyListeners();
        if (i + 1 < oldLength) {
          await _player.removeAudioSourceRange(i + 1, oldLength);
        }
        if (i > 0) await _player.removeAudioSourceRange(0, i);
        if (before.isNotEmpty) {
          await _player.insertAudioSources(0, before.map(_source).toList());
        }
        if (after.isNotEmpty) {
          await _player.addAudioSources(after.map(_source).toList());
        }
      }
    } catch (e) {
      debugPrint('Error al cambiar el aleatorio: $e');
    } finally {
      _busy = false;
      notifyListeners();
    }
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

  // ---------- Cola ----------

  /// Salta a una canción de la cola.
  Future<void> playAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    current = _queue[index];
    notifyListeners();
    await _player.seek(Duration.zero, index: index);
    if (!_player.playing) {
      _player.play().catchError((Object e) {
        debugPrint('Error al reproducir: $e');
      });
    }
  }

  /// Cambia de lugar una canción (recibe los índices de ReorderableListView).
  Future<void> moveInQueue(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _queue.length) return;

    _busy = true;
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);
    notifyListeners();
    try {
      await _player.moveAudioSource(oldIndex, newIndex);
    } catch (e) {
      debugPrint('Error al mover en la cola: $e');
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Quita una canción de la cola (la que está sonando no se puede quitar).
  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= _queue.length) return;
    if (index == _player.currentIndex) return;

    _busy = true;
    _queue.removeAt(index);
    notifyListeners();
    try {
      await _player.removeAudioSourceAt(index);
    } catch (e) {
      debugPrint('Error al quitar de la cola: $e');
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}