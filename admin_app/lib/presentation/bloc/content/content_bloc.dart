import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/track_model.dart';
import '../../../shared/services/firebase_service.dart';

// Events
abstract class ContentEvent {}

class LoadCategories extends ContentEvent {}

class LoadTracks extends ContentEvent {
  final String? categoryId;
  LoadTracks({this.categoryId});
}

class CreateCategory extends ContentEvent {
  final CategoryModel category;
  CreateCategory(this.category);
}

class UpdateCategory extends ContentEvent {
  final CategoryModel category;
  UpdateCategory(this.category);
}

class DeleteCategory extends ContentEvent {
  final String categoryId;
  DeleteCategory(this.categoryId);
}

class CreateTrack extends ContentEvent {
  final TrackModel track;
  final PlatformFile audioFile;
  final PlatformFile? imageFile;
  CreateTrack(this.track, this.audioFile, {this.imageFile});
}

class UpdateTrack extends ContentEvent {
  final TrackModel track;
  UpdateTrack(this.track);
}

class DeleteTrack extends ContentEvent {
  final String trackId;
  DeleteTrack(this.trackId);
}

class UploadFile extends ContentEvent {
  final PlatformFile file;
  final String path;
  UploadFile(this.file, this.path);
}

// States
abstract class ContentState {}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class CategoriesLoaded extends ContentState {
  final List<CategoryModel> categories;
  CategoriesLoaded(this.categories);
}

class TracksLoaded extends ContentState {
  final List<TrackModel> tracks;
  final String? categoryId;
  TracksLoaded(this.tracks, {this.categoryId});
}

class FileUploading extends ContentState {
  final double progress;
  FileUploading(this.progress);
}

class FileUploaded extends ContentState {
  final String url;
  FileUploaded(this.url);
}

class ContentSuccess extends ContentState {
  final String message;
  ContentSuccess(this.message);
}

class ContentError extends ContentState {
  final String message;
  ContentError(this.message);
}

// BLoC
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  ContentBloc() : super(ContentInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadTracks>(_onLoadTracks);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<CreateTrack>(_onCreateTrack);
    on<UpdateTrack>(_onUpdateTrack);
    on<DeleteTrack>(_onDeleteTrack);
    on<UploadFile>(_onUploadFile);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<ContentState> emit) async {
    emit(ContentLoading());
    
    try {
      await emit.forEach(
        FirebaseService.getCategoriesStream(),
        onData: (List<CategoryModel> categories) => CategoriesLoaded(categories),
        onError: (error, stackTrace) => ContentError('فشل في تحميل الأقسام'),
      );
    } catch (e) {
      emit(ContentError('فشل في تحميل الأقسام'));
    }
  }

  Future<void> _onLoadTracks(LoadTracks event, Emitter<ContentState> emit) async {
    emit(ContentLoading());
    
    try {
      if (event.categoryId != null) {
        await emit.forEach(
          FirebaseService.getTracksStream(event.categoryId!),
          onData: (List<TrackModel> tracks) => TracksLoaded(tracks, categoryId: event.categoryId),
          onError: (error, stackTrace) => ContentError('فشل في تحميل المقاطع الصوتية'),
        );
      } else {
        // Load all tracks
        // This would require a different Firebase query
        emit(TracksLoaded([]));
      }
    } catch (e) {
      emit(ContentError('فشل في تحميل المقاطع الصوتية'));
    }
  }

  Future<void> _onCreateCategory(CreateCategory event, Emitter<ContentState> emit) async {
    emit(ContentLoading());
    
    try {
      await FirebaseService.createCategory(event.category);
      emit(ContentSuccess('تم إنشاء القسم بنجاح'));
    } catch (e) {
      emit(ContentError('فشل في إنشاء القسم'));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<ContentState> emit) async {
    emit(ContentLoading());
    
    try {
      await FirebaseService.updateCategory(event.category);
      emit(ContentSuccess('تم تحديث القسم بنجاح'));
    } catch (e) {
      emit(ContentError('فشل في تحديث القسم'));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<ContentState> emit) async {
    emit(ContentLoading());
    
    try {
      await FirebaseService.deleteCategory(event.categoryId);
      emit(ContentSuccess('تم حذف القسم بنجاح'));
    } catch (e) {
      emit(ContentError('فشل في حذف القسم'));
    }
  }

  Future<void> _onCreateTrack(CreateTrack event, Emitter<ContentState> emit) async {
    emit(ContentLoading());
    
    try {
      // Upload audio file
      emit(FileUploading(0.0));
      final audioUrl = await FirebaseService.uploadFile(
        'tracks/${DateTime.now().millisecondsSinceEpoch}_${event.audioFile.name}',
        event.audioFile.bytes!,
      );
      
      String? imageUrl;
      if (event.imageFile != null) {
        emit(FileUploading(0.5));
        imageUrl = await FirebaseService.uploadFile(
          'track_images/${DateTime.now().millisecondsSinceEpoch}_${event.imageFile!.name}',
          event.imageFile!.bytes!,
        );
      }
      
      emit(FileUploading(0.8));
      
      // Create track with uploaded URLs
      final track = event.track.copyWith(
        audioUrl: audioUrl,
        imageUrl: imageUrl ?? event.track.imageUrl,
      );
      
      await FirebaseService.createTrack(track);
      emit(ContentSuccess('تم إنشاء المقطع الصوتي بنجاح'));
    } catch (e) {
      emit(ContentError('فشل في إنشاء المقطع الصوتي'));
    }
  }

  Future<void> _onUpdateTrack(UpdateTrack event, Emitter<ContentState> emit) async {
    emit(ContentLoading());
    
    try {
      await FirebaseService.updateTrack(event.track);
      emit(ContentSuccess('تم تحديث المقطع الصوتي بنجاح'));
    } catch (e) {
      emit(ContentError('فشل في تحديث المقطع الصوتي'));
    }
  }

  Future<void> _onDeleteTrack(DeleteTrack event, Emitter<ContentState> emit) async {
    emit(ContentLoading());
    
    try {
      await FirebaseService.deleteTrack(event.trackId);
      emit(ContentSuccess('تم حذف المقطع الصوتي بنجاح'));
    } catch (e) {
      emit(ContentError('فشل في حذف المقطع الصوتي'));
    }
  }

  Future<void> _onUploadFile(UploadFile event, Emitter<ContentState> emit) async {
    emit(FileUploading(0.0));
    
    try {
      final url = await FirebaseService.uploadFile(event.path, event.file.bytes!);
      emit(FileUploaded(url));
    } catch (e) {
      emit(ContentError('فشل في رفع الملف'));
    }
  }
}
