import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/track_model.dart';
import '../../../shared/services/firebase_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/download_service.dart';

// Events
abstract class MusicEvent {}

class LoadCategories extends MusicEvent {}

class LoadTracks extends MusicEvent {
  final String categoryId;
  LoadTracks(this.categoryId);
}

class PlayTrack extends MusicEvent {
  final TrackModel track;
  PlayTrack(this.track);
}

class PauseTrack extends MusicEvent {}

class ResumeTrack extends MusicEvent {}

class StopTrack extends MusicEvent {}

class SeekTrack extends MusicEvent {
  final Duration position;
  SeekTrack(this.position);
}

class DownloadTrack extends MusicEvent {
  final TrackModel track;
  DownloadTrack(this.track);
}

class DeleteDownloadedTrack extends MusicEvent {
  final String trackId;
  DeleteDownloadedTrack(this.trackId);
}

// States
abstract class MusicState {}

class MusicInitial extends MusicState {}

class MusicLoading extends MusicState {}

class CategoriesLoaded extends MusicState {
  final List<CategoryModel> categories;
  CategoriesLoaded(this.categories);
}

class TracksLoaded extends MusicState {
  final List<TrackModel> tracks;
  final String categoryId;
  TracksLoaded(this.tracks, this.categoryId);
}

class TrackPlaying extends MusicState {
  final TrackModel track;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  TrackPlaying(this.track, this.isPlaying, this.position, this.duration);
}

class TrackDownloading extends MusicState {
  final TrackModel track;
  final double progress;
  TrackDownloading(this.track, this.progress);
}

class TrackDownloaded extends MusicState {
  final TrackModel track;
  TrackDownloaded(this.track);
}

class MusicError extends MusicState {
  final String message;
  MusicError(this.message);
}

// BLoC
class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final AudioService _audioService = AudioService();
  final DownloadService _downloadService = DownloadService();

  MusicBloc() : super(MusicInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadTracks>(_onLoadTracks);
    on<PlayTrack>(_onPlayTrack);
    on<PauseTrack>(_onPauseTrack);
    on<ResumeTrack>(_onResumeTrack);
    on<StopTrack>(_onStopTrack);
    on<SeekTrack>(_onSeekTrack);
    on<DownloadTrack>(_onDownloadTrack);
    on<DeleteDownloadedTrack>(_onDeleteDownloadedTrack);

    _audioService.initialize();
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<MusicState> emit) async {
    emit(MusicLoading());
    
    try {
      await emit.forEach(
        FirebaseService.getCategoriesStream(),
        onData: (List<CategoryModel> categories) => CategoriesLoaded(categories),
        onError: (error, stackTrace) => MusicError('فشل في تحميل الأقسام'),
      );
    } catch (e) {
      emit(MusicError('فشل في تحميل الأقسام'));
    }
  }

  Future<void> _onLoadTracks(LoadTracks event, Emitter<MusicState> emit) async {
    emit(MusicLoading());
    
    try {
      await emit.forEach(
        FirebaseService.getTracksStream(event.categoryId),
        onData: (List<TrackModel> tracks) => TracksLoaded(tracks, event.categoryId),
        onError: (error, stackTrace) => MusicError('فشل في تحميل المقاطع الصوتية'),
      );
    } catch (e) {
      emit(MusicError('فشل في تحميل المقاطع الصوتية'));
    }
  }

  Future<void> _onPlayTrack(PlayTrack event, Emitter<MusicState> emit) async {
    try {
      // Check if track is downloaded locally
      final localPath = await _downloadService.getLocalTrackPath(event.track.id);
      
      await _audioService.playTrack(event.track, localPath: localPath);
      
      // Listen to audio player state changes
      await emit.forEach(
        _audioService.playingStream,
        onData: (bool isPlaying) {
          return TrackPlaying(
            event.track,
            isPlaying,
            _audioService.position,
            _audioService.duration,
          );
        },
      );
    } catch (e) {
      emit(MusicError('فشل في تشغيل المقطع الصوتي'));
    }
  }

  Future<void> _onPauseTrack(PauseTrack event, Emitter<MusicState> emit) async {
    try {
      await _audioService.pause();
    } catch (e) {
      emit(MusicError('فشل في إيقاف التشغيل مؤقتاً'));
    }
  }

  Future<void> _onResumeTrack(ResumeTrack event, Emitter<MusicState> emit) async {
    try {
      await _audioService.play();
    } catch (e) {
      emit(MusicError('فشل في استئناف التشغيل'));
    }
  }

  Future<void> _onStopTrack(StopTrack event, Emitter<MusicState> emit) async {
    try {
      await _audioService.stop();
      emit(MusicInitial());
    } catch (e) {
      emit(MusicError('فشل في إيقاف التشغيل'));
    }
  }

  Future<void> _onSeekTrack(SeekTrack event, Emitter<MusicState> emit) async {
    try {
      await _audioService.seek(event.position);
    } catch (e) {
      emit(MusicError('فشل في تغيير موضع التشغيل'));
    }
  }

  Future<void> _onDownloadTrack(DownloadTrack event, Emitter<MusicState> emit) async {
    try {
      // Check if already downloaded
      if (await _downloadService.isTrackDownloaded(event.track.id)) {
        emit(TrackDownloaded(event.track));
        return;
      }

      // Start download with progress updates
      await _downloadService.downloadTrack(
        event.track,
        onProgress: (progress) {
          emit(TrackDownloading(event.track, progress));
        },
      );

      emit(TrackDownloaded(event.track));
    } catch (e) {
      emit(MusicError('فشل في تحميل المقطع الصوتي'));
    }
  }

  Future<void> _onDeleteDownloadedTrack(DeleteDownloadedTrack event, Emitter<MusicState> emit) async {
    try {
      await _downloadService.deleteDownloadedTrack(event.trackId);
      // Emit success state or refresh current state
    } catch (e) {
      emit(MusicError('فشل في حذف المقطع الصوتي'));
    }
  }

  @override
  Future<void> close() {
    _audioService.dispose();
    return super.close();
  }
}
