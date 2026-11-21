import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/aero.dart';
import '../../../widgets/song_artwork.dart';
import '../providers/library_provider.dart';

class GroupTile extends StatelessWidget {
  final SongGroup group;
  final VoidCallback onTap;

  const GroupTile({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = group.songs.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: GlassTile(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        child: Row(
          children: [
            SongArtwork(id: group.songs.first.id),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
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
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}