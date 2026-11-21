import 'package:audio_service/audio_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/library/providers/library_provider.dart';
import 'features/library/screens/library_screen.dart';
import 'features/player/providers/player_provider.dart';
import 'features/player/services/audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = await AudioService.init(
    builder: () => UMusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.umusic.audio',
      androidNotificationChannelName: 'Reproducción de música',
      androidNotificationOngoing: true,
    ),
  );
  runApp(MusicApp(audioHandler: handler));
}

class MusicApp extends StatelessWidget {
  final UMusicAudioHandler audioHandler;

  const MusicApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(audioHandler.player),
        ),
      ],
      child: MaterialApp(
        title: 'uMusic',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        home: const LibraryScreen(),
      ),
    );
  }
}