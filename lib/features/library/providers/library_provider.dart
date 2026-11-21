import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/text_utils.dart';

enum LibraryTab { songs, favorites, playlists, albums, artists, genres }

class SongGroup {
  final String name;
  final List<SongModel> songs;
  const SongGroup(this.name, this.songs);
}

class LibraryProvider extends ChangeNotifier {
  final OnAudioQuery _query = OnAudioQuery();

  List<SongModel> songs = [];
  List<SongModel> visibleSongs = [];
  List<SongGroup> visibleGroups = [];
  bool loading = true;
  bool permissionDenied = false;

  LibraryTab tab = LibraryTab.songs;
  String query = '';
  String _normQuery = '';

  final Map<LibraryTab, List<SongGroup>> _groups = {};
  final Map<int, String> _haystack = {};
  final Map<int, SongModel> _byId = {};

  void setTab(LibraryTab t) {
    tab = t;
    _applyFilter();
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    _normQuery = normalize(q);
    _applyFilter();
    notifyListeners();
  }

  /// Convierte identificadores en canciones, omitiendo las que ya no existen.
  List<SongModel> songsFor(Iterable<int> ids) {
    final result = <SongModel>[];
    for (final id in ids) {
      final song = _byId[id];
      if (song != null) result.add(song);
    }
    return result;
  }

  /// Indica si una canción coincide con la búsqueda actual.
  bool matchesQuery(SongModel s) {
    if (_normQuery.isEmpty) return true;
    return (_haystack[s.id] ?? '').contains(_normQuery);
  }

  Future<void> load() async {
    loading = true;
    permissionDenied = false;
    notifyListeners();

    try {
      final granted = await _requestPermission();
      if (!granted) {
        permissionDenied = true;
        return;
      }

      await _requestNotificationPermission();

      final result = await _query.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Descarta audios muy cortos (tonos, notas de voz)
      songs = result.where((s) => (s.duration ?? 0) > 30000).toList();
      _buildIndex();
      _buildGroups();
      _applyFilter();
    } catch (e) {
      debugPrint('Error al cargar la biblioteca: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String _clean(String? v, String fallback) {
    if (v == null || v.isEmpty || v == '<unknown>') return fallback;
    return v;
  }

  void _buildIndex() {
    _haystack.clear();
    _byId.clear();
    for (final s in songs) {
      _byId[s.id] = s;
      _haystack[s.id] = normalize(
        '${s.title} ${_clean(s.artist, '')} ${_clean(s.album, '')}',
      );
    }
  }

  void _buildGroups() {
    _groups[LibraryTab.albums] = _groupBy(
      (s) => _clean(s.album, 'Álbum desconocido'),
      sortSongs: (a, b) => (a.track ?? 0).compareTo(b.track ?? 0),
    );
    _groups[LibraryTab.artists] =
        _groupBy((s) => _clean(s.artist, 'Artista desconocido'));
    _groups[LibraryTab.genres] =
        _groupBy((s) => _clean(s.genre, 'Sin género'));
  }

  List<SongGroup> _groupBy(
    String Function(SongModel) key, {
    int Function(SongModel, SongModel)? sortSongs,
  }) {
    final map = <String, List<SongModel>>{};
    for (final s in songs) {
      map.putIfAbsent(key(s), () => []).add(s);
    }
    if (sortSongs != null) {
      for (final list in map.values) {
        list.sort(sortSongs);
      }
    }
    return map.entries.map((e) => SongGroup(e.key, e.value)).toList()
      ..sort((a, b) => normalize(a.name).compareTo(normalize(b.name)));
  }

  void _applyFilter() {
    final q = _normQuery;
    if (tab == LibraryTab.songs) {
      visibleSongs = q.isEmpty
          ? songs
          : songs.where((s) => (_haystack[s.id] ?? '').contains(q)).toList();
    } else {
      // Favoritos y playlists se filtran en su propia vista
      final all = _groups[tab] ?? const <SongGroup>[];
      visibleGroups = q.isEmpty
          ? all
          : all.where((g) => normalize(g.name).contains(q)).toList();
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      return (await Permission.mediaLibrary.request()).isGranted;
    }

    if (await Permission.audio.isGranted) return true;

    // Al arrancar, la Activity a veces aún no está lista: reintenta
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        var status = await Permission.audio.request();
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      } on PlatformException {
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }
    return false;
  }

  // Android 13+ pide permiso para mostrar notificaciones
  Future<void> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return;
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } catch (e) {
      debugPrint('Error al pedir permiso de notificaciones: $e');
    }
  }
}