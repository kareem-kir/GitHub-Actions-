import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import '../../shared/models/track_model.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  TrackModel? _currentTrack;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  TrackModel? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;

  Future<void> initialize() async {
    // Listen to player state changes
    _audioPlayer.playingStream.listen((playing) {
      _isPlaying = playing;
    });

    _audioPlayer.positionStream.listen((position) {
      _position = position;
    });

    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
    });

    // Handle player completion
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  Future<void> playTrack(TrackModel track, {String? localPath}) async {
    try {
      _currentTrack = track;
      
      String audioSource;
      if (localPath != null && await File(localPath).exists()) {
        audioSource = localPath;
      } else {
        audioSource = track.audioUrl;
      }

      await _audioPlayer.setUrl(audioSource);
      await _audioPlayer.play();
      
      // Update play count in Firebase
      // FirebaseService.incrementTrackPlayCount(track.id);
    } catch (e) {
      print('Error playing track: $e');
      throw Exception('فشل في تشغيل المقطع الصوتي');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentTrack = null;
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  void _onTrackCompleted() {
    // Handle track completion (e.g., play next track)
    print('Track completed: ${_currentTrack?.title}');
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

// Audio Handler for background playback
class MusicAudioHandler extends BaseAudioHandler {
  final AudioService _audioService = AudioService();

  MusicAudioHandler() {
    _audioService.initialize();
  }

  @override
  Future<void> play() async {
    await _audioService.play();
  }

  @override
  Future<void> pause() async {
    await _audioService.pause();
  }

  @override
  Future<void> stop() async {
    await _audioService.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }
}
