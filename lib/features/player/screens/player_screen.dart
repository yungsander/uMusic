import 'package:just_audio/just_audio.dart' show LoopMode;
import 'package:material_ui/material_ui.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/song_utils.dart';
import '../../../widgets/aero.dart';
import '../providers/player_provider.dart';
import '../widgets/progress_bar.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.current;
    if (song == null) return const AeroScaffold(body: SizedBox.shrink());

    final screen = MediaQuery.of(context).size;
    final side = (screen.width - 64).clamp(0.0, screen.height * 0.4).toDouble();

    return AeroScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reproduciendo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            _artwork(song, side, player.isPlaying),
            const SizedBox(height: 28),
            GlassCard(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              radius: 28,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ProgressBar(),
                  const SizedBox(height: 8),
                  _controls(player),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _artwork(SongModel song, double side, bool playing) {
    return AnimatedScale(
      scale: playing ? 1.0 : 0.92,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55062E7A),
              blurRadius: 40,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: QueryArtworkWidget(
            key: ValueKey(song.id),
            id: song.id,
            type: ArtworkType.AUDIO,
            size: 800,
            quality: 100,
            keepOldArtwork: true,
            artworkWidth: side,
            artworkHeight: side,
            artworkFit: BoxFit.cover,
            artworkBorder: BorderRadius.circular(26),
            nullArtworkWidget: Container(
              width: side,
              height: side,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x66FFFFFF), Color(0x1FFFFFFF)],
                ),
              ),
              child: const Icon(
                Icons.music_note_outlined,
                size: 72,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls(PlayerProvider player) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color:
                  player.shuffle ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: player.toggleShuffle,
          ),
          const SizedBox(width: 4),
          IconButton(
            iconSize: 36,
            icon: const Icon(Icons.skip_previous),
            onPressed: player.previous,
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            iconSize: 36,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.skyTop,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: player.togglePlay,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                player.isPlaying ? Icons.pause : Icons.play_arrow,
                key: ValueKey(player.isPlaying),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            iconSize: 36,
            icon: const Icon(Icons.skip_next),
            onPressed: player.next,
          ),
          const SizedBox(width: 4),
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
    );
  }
}