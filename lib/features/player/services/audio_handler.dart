import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Conecta just_audio con la notificación y la pantalla de bloqueo.
class UMusicAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();

  UMusicAudioHandler() {
    player.playbackEventStream.listen((event) {
      playbackState.add(_transform(event));
    });

    // La notificación muestra los datos de la canción actual
    player.sequenceStateStream.listen((state) {
      final tag = state.currentSource?.tag;
      if (tag is MediaItem) mediaItem.add(tag);
    });
  }

  PlaybackState _transform(PlaybackEvent event) {
    return PlaybackState(
      // Botones de la notificación: sin "detener"
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() => player.seekToNext();

  @override
  Future<void> skipToPrevious() => player.seekToPrevious();

  @override
  Future<void> stop() async {
    // Ya no hay botón de detener. Si el sistema lo pide (por ejemplo al
    // descartar la notificación), solo se pausa.
    await player.pause();
  }
}