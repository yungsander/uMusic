import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/song_utils.dart';
import '../../../widgets/aero.dart';
import '../providers/player_provider.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  static const double _itemHeight = 76;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    // Abre la lista centrada cerca de la canción que suena
    final idx = context.read<PlayerProvider>().currentQueueIndex;
    _scroll = ScrollController(
      initialScrollOffset: max(0, idx - 1) * _itemHeight,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final queue = player.queue;
    final currentId = player.current?.id;

    return AeroScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cola de reproducción',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              '${queue.length} canciones',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: queue.isEmpty
          ? const Center(child: Text('La cola está vacía'))
          : ReorderableListView.builder(
              scrollController: _scroll,
              itemExtent: _itemHeight,
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              proxyDecorator: (child, index, animation) =>
                  Material(type: MaterialType.transparency, child: child),
              itemCount: queue.length,
              onReorder: player.moveInQueue,
              itemBuilder: (context, i) {
                final song = queue[i];
                final isCurrent = song.id == currentId;
                return _QueueTile(
                  key: ValueKey(song.id),
                  index: i,
                  song: song,
                  isCurrent: isCurrent,
                  onTap: () => player.playAt(i),
                  onRemove: isCurrent ? null : () => player.removeFromQueue(i),
                );
              },
            ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  final int index;
  final SongModel song;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _QueueTile({
    super.key,
    required this.index,
    required this.song,
    required this.isCurrent,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tile = GlassTile(
      onTap: onTap,
      highlighted: isCurrent,
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      child: Row(
        children: [
          QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            size: 150,
            keepOldArtwork: true,
            artworkWidth: 46,
            artworkHeight: 46,
            artworkBorder: BorderRadius.circular(14),
            nullArtworkWidget: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0x99FFFFFF),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.music_note_outlined,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrent ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song.artistName,
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
          if (isCurrent)
            const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.graphic_eq, color: AppColors.primary),
            )
          else
            IconButton(
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: onRemove,
            ),
          ReorderableDragStartListener(
            index: index,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.drag_handle, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: isCurrent
          ? tile
          : Dismissible(
              key: ValueKey('dismiss-${song.id}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onRemove?.call(),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: const Color(0x40E53935),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textPrimary,
                ),
              ),
              child: tile,
            ),
    );
  }
}