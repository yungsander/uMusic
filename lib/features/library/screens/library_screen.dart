import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/aero.dart';
import '../../../widgets/mini_player.dart';
import '../../player/providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/group_tile.dart';
import '../widgets/search_field.dart';
import '../widgets/song_tile.dart';
import 'group_screen.dart';

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
    final currentId =
        context.select<PlayerProvider, int?>((p) => p.current?.id);

    return AeroScaffold(
      appBar: AppBar(
        title: const Text(
          'Mi música',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          const SearchField(),
          const CategoryChips(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(lib.tab),
                child: _content(lib, currentId),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _message(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );

  Widget _content(LibraryProvider lib, int? currentId) {
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
      return _message('No se encontraron canciones');
    }

    if (lib.tab == LibraryTab.songs) {
      if (lib.visibleSongs.isEmpty) {
        return _message('Sin resultados para «${lib.query}»');
      }
      return ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        itemCount: lib.visibleSongs.length,
        itemBuilder: (_, i) {
          final song = lib.visibleSongs[i];
          return SongTile(
            song: song,
            isCurrent: song.id == currentId,
            onTap: () =>
                context.read<PlayerProvider>().playQueue(lib.visibleSongs, i),
          );
        },
      );
    }

    if (lib.visibleGroups.isEmpty) {
      return _message('Sin resultados para «${lib.query}»');
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      itemCount: lib.visibleGroups.length,
      itemBuilder: (_, i) {
        final group = lib.visibleGroups[i];
        return GroupTile(
          group: group,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => GroupScreen(group: group)),
          ),
        );
      },
    );
  }
}