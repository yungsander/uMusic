import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/library_provider.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  static const _labels = {
    LibraryTab.songs: 'Canciones',
    LibraryTab.albums: 'Álbumes',
    LibraryTab.artists: 'Artistas',
    LibraryTab.genres: 'Géneros',
  };

  @override
  Widget build(BuildContext context) {
    final tab = context.select<LibraryProvider, LibraryTab>((p) => p.tab);

    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        children: [
          for (final t in LibraryTab.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: _labels[t]!,
                selected: t == tab,
                onTap: () => context.read<LibraryProvider>().setTab(t),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? AppColors.primary : const Color(0x99FFFFFF),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xB3FFFFFF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}