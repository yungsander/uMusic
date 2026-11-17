import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/library/providers/library_provider.dart';
import 'features/library/screens/library_screen.dart';

void main() => runApp(const MusicApp());

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryProvider(),
      child: MaterialApp(
        title: 'uMusic',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        home: const LibraryScreen(),
      ),
    );
  }
}