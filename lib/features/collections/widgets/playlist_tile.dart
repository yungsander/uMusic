import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/aero.dart';
import '../../../widgets/song_artwork.dart';
import '../providers/playlists_provider.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final int? coverSongId;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const PlaylistTile({
    super.key,
    required this.playlist,
    required this.coverSongId,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final n = playlist.songIds.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: GlassTile(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
        child: Row(
          children: [
            if (coverSongId != null)
              SongArtwork(id: coverSongId!)
            else
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0x99FFFFFF),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.queue_music,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
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
                    '$n ${n == 1 ? 'canción' : 'canciones'}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'rename') {
                  onRename();
                } else {
                  onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Renombrar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}