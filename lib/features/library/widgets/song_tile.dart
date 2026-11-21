import 'package:flutter/services.dart' show HapticFeedback;
import 'package:material_ui/material_ui.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/aero.dart';
import '../../../widgets/song_artwork.dart';
import '../../collections/providers/playlists_provider.dart';
import '../../collections/widgets/song_options_sheet.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final bool isCurrent;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isCurrent = false,
  });

  String _format(int? ms) {
    final d = Duration(milliseconds: ms ?? 0);
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _artist {
    final a = song.artist;
    if (a == null || a.isEmpty || a == '<unknown>') {
      return 'Artista desconocido';
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    final isFav = context
        .select<PlaylistsProvider, bool>((p) => p.isFavorite(song.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: GlassTile(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showSongOptions(context, song);
        },
        highlighted: isCurrent,
        padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
        child: Row(
          children: [
            SongArtwork(id: song.id),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isFav)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.favorite, size: 16, color: kHeartColor),
              ),
            Text(
              _format(song.duration),
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}