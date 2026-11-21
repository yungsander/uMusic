import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../core/theme/app_theme.dart';

/// Guarda las carátulas en memoria para no pedirlas al sistema en cada scroll.
class ArtworkCache {
  static final OnAudioQuery _query = OnAudioQuery();
  static final Map<String, Uint8List?> _cache = {};
  static final Map<String, Future<Uint8List?>> _pending = {};
  static const int _maxEntries = 400;

  static String _key(int id, int size) => '$id:$size';

  static bool has(int id, int size) => _cache.containsKey(_key(id, size));
  static Uint8List? peek(int id, int size) => _cache[_key(id, size)];

  static Future<Uint8List?> load(int id, {int size = 150}) {
    final key = _key(id, size);
    if (_cache.containsKey(key)) return SynchronousFuture(_cache[key]);

    return _pending.putIfAbsent(key, () async {
      Uint8List? bytes;
      try {
        bytes = await _query.queryArtwork(
          id,
          ArtworkType.AUDIO,
          format: ArtworkFormat.JPEG,
          size: size,
          quality: 80,
        );
      } catch (_) {
        bytes = null;
      }
      _cache[key] = bytes;
      if (_cache.length > _maxEntries) _cache.remove(_cache.keys.first);
      _pending.remove(key);
      return bytes;
    });
  }
}

class SongArtwork extends StatefulWidget {
  final int id;
  final double size;
  final double radius;
  final int resolution;
  final double iconSize;

  const SongArtwork({
    super.key,
    required this.id,
    this.size = 46,
    this.radius = 14,
    this.resolution = 150,
    this.iconSize = 24,
  });

  @override
  State<SongArtwork> createState() => _SongArtworkState();
}

class _SongArtworkState extends State<SongArtwork> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant SongArtwork old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id || old.resolution != widget.resolution) {
      _resolve();
    }
  }

  void _resolve() {
    final id = widget.id;
    final res = widget.resolution;

    if (ArtworkCache.has(id, res)) {
      _bytes = ArtworkCache.peek(id, res);
      return;
    }

    // Mientras carga se conserva la imagen anterior (sin parpadeos)
    ArtworkCache.load(id, size: res).then((b) {
      if (!mounted || id != widget.id || res != widget.resolution) return;
      setState(() => _bytes = b);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final bytes = _bytes;
    final radius = BorderRadius.circular(widget.radius);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: radius,
        child: (bytes == null || bytes.isEmpty)
            ? Container(
                decoration: BoxDecoration(
                  color: const Color(0x99FFFFFF),
                  border: Border.all(color: AppColors.border),
                  borderRadius: radius,
                ),
                child: Icon(
                  Icons.music_note_outlined,
                  size: widget.iconSize,
                  color: AppColors.textSecondary,
                ),
              )
            : Image.memory(
                bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                cacheWidth: (widget.size * dpr).round(),
                filterQuality: FilterQuality.medium,
              ),
      ),
    );
  }
}