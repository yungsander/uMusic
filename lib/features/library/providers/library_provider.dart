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

    final granted = await _requestPermission();
    if (!granted) {
      permissionDenied = true;
      loading = false;
      notifyListeners();
      return;
    }

    final result = await _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true, 
    );

    songs = result.where((s) => (s.duration ?? 0) > 30000).toList();
    loading = false;
    notifyListeners();
  }

  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      return (await Permission.mediaLibrary.request()).isGranted;
    }
    var status = await Permission.audio.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}