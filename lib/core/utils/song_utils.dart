import 'package:on_audio_query/on_audio_query.dart';

extension SongX on SongModel {
  String get artistName {
    final a = artist;
    if (a == null || a.isEmpty || a == '<unknown>') return 'Artista Desconocido';
    return a;
  }
}

String formatDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}