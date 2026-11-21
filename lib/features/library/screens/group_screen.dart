import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../../widgets/aero.dart';
import '../../../widgets/mini_player.dart';
import '../../player/providers/player_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/song_tile.dart';

class GroupScreen extends StatelessWidget {
  final SongGroup group;

  const GroupScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final currentId =
        context.select<PlayerProvider, int?>((p) => p.current?.id);

    return AeroScaffold(
      appBar: AppBar(
        title: Text(
          group.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        itemCount: group.songs.length,
        itemBuilder: (_, i) => SongTile(
          song: group.songs[i],
          isCurrent: group.songs[i].id == currentId,
          onTap: () =>
              context.read<PlayerProvider>().playQueue(group.songs, i),
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}