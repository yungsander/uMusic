import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/aero.dart';
import '../../../widgets/mini_player.dart';
import '../../library/providers/library_provider.dart';
import '../../library/widgets/song_tile.dart';
import '../../player/providers/player_provider.dart';
import '../providers/playlists_provider.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final collections = context.watch<PlaylistsProvider>();
    final playlist = collections.byId(playlistId);

    if (playlist == null) {
      return const AeroScaffold(
        body: Center(child: Text('La playlist ya no existe')),
      );
    }

    final songs = context.read<LibraryProvider>().songsFor(playlist.songIds);
    final player = context.read<PlayerProvider>();
    final currentId =
        context.select<PlayerProvider, int?>((p) => p.current?.id);

    return AeroScaffold(
      appBar: AppBar(
        title: Text(
          playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: songs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Esta playlist está vacía.\n'
                  'Mantén presionada una canción y elige «Agregar a una playlist».',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => player.playQueue(songs, 0),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Reproducir'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => player.playShuffled(songs),
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Aleatorio'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    itemCount: songs.length,
                    itemBuilder: (_, i) {
                      final song = songs[i];
                      return Dismissible(
                        key: ValueKey('pl-${playlist.id}-${song.id}'),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (_) => collections.removeFromPlaylist(
                          playlist.id,
                          song.id,
                        ),
                        background: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 24),
                          decoration: BoxDecoration(
                            color: const Color(0x40E53935),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        child: SongTile(
                          song: song,
                          isCurrent: song.id == currentId,
                          onTap: () => player.playQueue(songs, i),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}