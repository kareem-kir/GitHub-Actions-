import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/track_model.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, CancelToken> _downloadTokens = {};
  final Map<String, double> _downloadProgress = {};

  // Get downloads directory
  Future<Directory> get _downloadsDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir;
  }

  // Check if track is downloaded
  Future<bool> isTrackDownloaded(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedTracks = prefs.getStringList('downloaded_tracks') ?? [];
    return downloadedTracks.contains(trackId);
  }

  // Get local path for track
  Future<String?> getLocalTrackPath(String trackId) async {
    if (!await isTrackDownloaded(trackId)) return null;
    
    final downloadsDir = await _downloadsDirectory;
    final file = File('${downloadsDir.path}/$trackId.mp3');
    
    if (await file.exists()) {
      return file.path;
    }
    
    // Remove from downloaded list if file doesn't exist
    await _removeFromDownloadedList(trackId);
    return null;
  }

  // Download track
  Future<String> downloadTrack(
    TrackModel track, {
    Function(double)? onProgress,
  }) async {
    try {
      final downloadsDir = await _downloadsDirectory;
      final filePath = '${downloadsDir.path}/${track.id}.mp3';
      final file = File(filePath);

      // Check if already downloaded
      if (await file.exists()) {
        await _addToDownloadedList(track.id);
        return filePath;
      }

      // Create cancel token
      final cancelToken = CancelToken();
      _downloadTokens[track.id] = cancelToken;

      // Download file
      await _dio.download(
        track.audioUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _downloadProgress[track.id] = progress;
            onProgress?.call(progress);
          }
        },
      );

      // Add to downloaded list
      await _addToDownloadedList(track.id);
      
      // Clean up
      _downloadTokens.remove(track.id);
      _downloadProgress.remove(track.id);

      // Update download count in Firebase
      // FirebaseService.incrementTrackDownloadCount(track.id);

      return filePath;
    } catch (e) {
      // Clean up on error
      _downloadTokens.remove(track.id);
      _downloadProgress.remove(track.id);
      
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw Exception('تم إلغاء التحميل');
      }
      
      print('Download error: $e');
      throw Exception('فشل في تحميل المقطع الصوتي');
    }
  }

  // Cancel download
  Future<void> cancelDownload(String trackId) async {
    final cancelToken = _downloadTokens[trackId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel();
    }
    
    _downloadTokens.remove(trackId);
    _downloadProgress.remove(trackId);
  }

  // Delete downloaded track
  Future<void> deleteDownloadedTrack(String trackId) async {
    try {
      final downloadsDir = await _downloadsDirectory;
      final file = File('${downloadsDir.path}/$trackId.mp3');
      
      if (await file.exists()) {
        await file.delete();
      }
      
      await _removeFromDownloadedList(trackId);
    } catch (e) {
      print('Error deleting track: $e');
      throw Exception('فشل في حذف المقطع الصوتي');
    }
  }

  // Get download progress
  double getDownloadProgress(String trackId) {
    return _downloadProgress[trackId] ?? 0.0;
  }

  // Check if track is downloading
  bool isTrackDownloading(String trackId) {
    return _downloadTokens.containsKey(trackId);
  }

  // Get all downloaded tracks
  Future<List<String>> getDownloadedTracks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('downloaded_tracks') ?? [];
  }

  // Get downloaded tracks size
  Future<double> getDownloadedSize() async {
    try {
      final downloadsDir = await _downloadsDirectory;
      final files = downloadsDir.listSync();
      double totalSize = 0;
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize / (1024 * 1024); // Convert to MB
    } catch (e) {
      return 0;
    }
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      final downloadsDir = await _downloadsDirectory;
      final files = downloadsDir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          await file.delete();
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('downloaded_tracks');
    } catch (e) {
      print('Error clearing downloads: $e');
      throw Exception('فشل في مسح التحميلات');
    }
  }

  // Private methods
  Future<void> _addToDownloadedList(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedTracks = prefs.getStringList('downloaded_tracks') ?? [];
    
    if (!downloadedTracks.contains(trackId)) {
      downloadedTracks.add(trackId);
      await prefs.setStringList('downloaded_tracks', downloadedTracks);
    }
  }

  Future<void> _removeFromDownloadedList(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedTracks = prefs.getStringList('downloaded_tracks') ?? [];
    
    downloadedTracks.remove(trackId);
    await prefs.setStringList('downloaded_tracks', downloadedTracks);
  }
}
