import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class LibraryProvider extends ChangeNotifier {
  final OnAudioQuery _query = OnAudioQuery();

  List<SongModel> songs = [];
  bool loading = true;
  bool permissionDenied = false;

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

      final result = await _query.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Descarta audios muy cortos (tonos, notas de voz)
      songs = result.where((s) => (s.duration ?? 0) > 30000).toList();
    } catch (e) {
      debugPrint('Error al cargar la biblioteca: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      return (await Permission.mediaLibrary.request()).isGranted;
    }

    // Si ya está concedido, no hace falta volver a pedirlo
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
}