import 'package:just_audio/just_audio.dart' show LoopMode;
import 'package:material_ui/material_ui.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/song_utils.dart';
import '../providers/player_provider.dart';
import '../widgets/progress_bar.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.current;
    if (song == null) return const Scaffold();

    final side = MediaQuery.of(context).size.width - 64;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Reproduciendo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 16),
            QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              size: 800,
              quality: 100,
              artworkWidth: side,
              artworkHeight: side,
              artworkFit: BoxFit.cover,
              artworkBorder: BorderRadius.circular(24),
              nullArtworkWidget: Container(
                width: side,
                height: side,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.music_note_outlined,
                    size: 72, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                song.artistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            const ProgressBar(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.shuffle,
                      color: player.shuffle
                          ? AppColors.primary
                          : AppColors.textSecondary),
                  onPressed: player.toggleShuffle,
                ),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: player.previous,
                ),
                IconButton.filled(
                  iconSize: 36,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: Icon(
                      player.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: player.togglePlay,
                ),
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.skip_next),
                  onPressed: player.next,
                ),
                IconButton(
                  icon: Icon(
                    player.loopMode == LoopMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                    color: player.loopMode == LoopMode.off
                        ? AppColors.textSecondary
                        : AppColors.primary,
                  ),
                  onPressed: player.cycleLoop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}