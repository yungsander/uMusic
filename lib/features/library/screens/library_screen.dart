import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/aero.dart';
import '../../../widgets/mini_player.dart';
import '../../player/providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryProvider>();
    // Solo se reconstruye cuando cambia la canción actual
    final currentId =
        context.select<PlayerProvider, int?>((p) => p.current?.id);

    return AeroScaffold(
      appBar: AppBar(
        title: const Text('Canciones',
            style: TextStyle(fontWeight: FontWeight.w600)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: _body(lib, currentId),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _body(LibraryProvider lib, int? currentId) {
    if (lib.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (lib.permissionDenied) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Necesitamos acceso a tu música'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => lib.load(),
              child: const Text('Dar permiso'),
            ),
          ],
        ),
      );
    }
    if (lib.songs.isEmpty) {
      return const Center(child: Text('No se encontraron canciones'));
    }
    return ListView.builder(
      itemCount: lib.songs.length,
      itemBuilder: (_, i) => SongTile(
        song: lib.songs[i],
        isCurrent: lib.songs[i].id == currentId,
        onTap: () => context.read<PlayerProvider>().playQueue(lib.songs, i),
      ),
    );
  }
}