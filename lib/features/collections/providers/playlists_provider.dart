import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Playlist {
  final String id;
  String name;
  final List<int> songIds;

  Playlist({required this.id, required this.name, List<int>? songIds})
      : songIds = songIds ?? [];

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'songs': songIds};

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        songIds: (json['songs'] as List).map((e) => e as int).toList(),
      );
}

/// Favoritos y playlists, guardados en el teléfono.
class PlaylistsProvider extends ChangeNotifier {
  static const _storageKey = 'umusic_collections_v1';

  final List<int> _favorites = []; // el más reciente primero
  final List<Playlist> _playlists = [];

  PlaylistsProvider() {
    _load();
  }

  List<int> get favoriteIds => List.unmodifiable(_favorites);
  List<Playlist> get playlists => List.unmodifiable(_playlists);

  bool isFavorite(int songId) => _favorites.contains(songId);

  Playlist? byId(String id) {
    for (final p in _playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ---------- Favoritos ----------

  void toggleFavorite(int songId) {
    if (!_favorites.remove(songId)) _favorites.insert(0, songId);
    notifyListeners();
    _save();
  }

  // ---------- Playlists ----------

  String createPlaylist(String name, {List<int> songIds = const []}) {
    final playlist = Playlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      songIds: List.of(songIds),
    );
    _playlists.add(playlist);
    notifyListeners();
    _save();
    return playlist.id;
  }

  void renamePlaylist(String id, String name) {
    final p = byId(id);
    if (p == null) return;
    p.name = name.trim();
    notifyListeners();
    _save();
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
    _save();
  }

  /// Devuelve false si la canción ya estaba en la playlist.
  bool addToPlaylist(String playlistId, int songId) {
    final p = byId(playlistId);
    if (p == null || p.songIds.contains(songId)) return false;
    p.songIds.add(songId);
    notifyListeners();
    _save();
    return true;
  }

  void removeFromPlaylist(String playlistId, int songId) {
    final p = byId(playlistId);
    if (p == null) return;
    p.songIds.remove(songId);
    notifyListeners();
    _save();
  }

  // ---------- Almacenamiento ----------

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _favorites
          ..clear()
          ..addAll(((data['favorites'] as List?) ?? []).map((e) => e as int));
        _playlists
          ..clear()
          ..addAll(((data['playlists'] as List?) ?? [])
              .map((e) => Playlist.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      debugPrint('Error al cargar favoritos y playlists: $e');
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode({
          'favorites': _favorites,
          'playlists': _playlists.map((p) => p.toJson()).toList(),
        }),
      );
    } catch (e) {
      debugPrint('Error al guardar favoritos y playlists: $e');
    }
  }
}