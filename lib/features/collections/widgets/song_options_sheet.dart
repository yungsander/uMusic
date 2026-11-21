import 'package:material_ui/material_ui.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/song_utils.dart';
import '../../../widgets/aero.dart';
import '../providers/playlists_provider.dart';
import 'name_dialog.dart';

const Color kHeartColor = Color(0xFFE5486B);

/// Menú de una canción: favorito y agregar a playlist.
Future<void> showSongOptions(BuildContext context, SongModel song) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (_) => _SheetFrame(
      child: _SongOptions(song: song, parentContext: context),
    ),
  );
}

/// Lista de playlists para agregar la canción.
Future<void> showPlaylistPicker(BuildContext context, SongModel song) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    builder: (_) => _SheetFrame(
      child: _PlaylistPicker(song: song, parentContext: context),
    ),
  );
}

void _toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

class _SheetFrame extends StatelessWidget {
  final Widget child;
  const _SheetFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GlassCard(
          blur: false,
          radius: 28,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    );
  }
}

class _SongOptions extends StatelessWidget {
  final SongModel song;
  final BuildContext parentContext;

  const _SongOptions({required this.song, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<PlaylistsProvider>().isFavorite(song.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            song.artistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: kHeartColor,
          ),
          title: Text(isFav ? 'Quitar de favoritos' : 'Agregar a favoritos'),
          onTap: () {
            context.read<PlaylistsProvider>().toggleFavorite(song.id);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Agregar a una playlist'),
          onTap: () {
            Navigator.of(context).pop();
            if (parentContext.mounted) showPlaylistPicker(parentContext, song);
          },
        ),
      ],
    );
  }
}

class _PlaylistPicker extends StatelessWidget {
  final SongModel song;
  final BuildContext parentContext;

  const _PlaylistPicker({required this.song, required this.parentContext});

  Future<void> _createNew(BuildContext context) async {
    final provider = context.read<PlaylistsProvider>();
    Navigator.of(context).pop();
    if (!parentContext.mounted) return;

    final name = await promptName(
      parentContext,
      title: 'Nueva playlist',
      confirmLabel: 'Crear',
    );
    if (name == null) return;

    provider.createPlaylist(name, songIds: [song.id]);
    if (parentContext.mounted) _toast(parentContext, 'Agregada a «$name»');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaylistsProvider>();
    final maxHeight = MediaQuery.of(context).size.height * 0.55;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView(
        shrinkWrap: true,
        children: [
          const ListTile(
            title: Text(
              'Agregar a playlist',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nueva playlist'),
            onTap: () => _createNew(context),
          ),
          for (final p in provider.playlists)
            ListTile(
              leading: const Icon(Icons.queue_music),
              title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${p.songIds.length} canciones'),
              trailing: p.songIds.contains(song.id)
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                final added = provider.addToPlaylist(p.id, song.id);
                Navigator.of(context).pop();
                if (parentContext.mounted) {
                  _toast(
                    parentContext,
                    added ? 'Agregada a «${p.name}»' : 'Ya estaba en «${p.name}»',
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}