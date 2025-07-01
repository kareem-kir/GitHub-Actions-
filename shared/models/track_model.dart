// Removed Firebase import

class TrackModel {
  final String id;
  final String title;
  final String titleAr;
  final String artist;
  final String artistAr;
  final String categoryId;
  final String audioUrl;
  final String imageUrl;
  final int duration; // in seconds
  final bool isLocked;
  final String requiredSubscription;
  final int downloadCount;
  final int playCount;
  final bool isActive;
  final int order;
  final DateTime createdAt;

  TrackModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.artist,
    required this.artistAr,
    required this.categoryId,
    required this.audioUrl,
    required this.imageUrl,
    required this.duration,
    required this.isLocked,
    required this.requiredSubscription,
    required this.downloadCount,
    required this.playCount,
    required this.isActive,
    required this.order,
    required this.createdAt,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['title_ar'] ?? '',
      artist: json['artist'] ?? '',
      artistAr: json['artist_ar'] ?? '',
      categoryId: json['category_id'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      duration: json['duration'] ?? 0,
      isLocked: json['is_locked'] ?? false,
      requiredSubscription: json['required_subscription'] ?? 'free',
      downloadCount: json['download_count'] ?? 0,
      playCount: json['play_count'] ?? 0,
      isActive: json['is_active'] ?? true,
      order: json['order_index'] ?? 0,
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'artist': artist,
      'artist_ar': artistAr,
      'category_id': categoryId,
      'audio_url': audioUrl,
      'image_url': imageUrl,
      'duration': duration,
      'is_locked': isLocked,
      'required_subscription': requiredSubscription,
      'download_count': downloadCount,
      'play_count': playCount,
      'is_active': isActive,
      'order_index': order,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  TrackModel copyWith({
    String? title,
    String? titleAr,
    String? artist,
    String? artistAr,
    String? categoryId,
    String? audioUrl,
    String? imageUrl,
    int? duration,
    bool? isLocked,
    String? requiredSubscription,
    int? downloadCount,
    int? playCount,
    bool? isActive,
    int? order,
  }) {
    return TrackModel(
      id: id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      artist: artist ?? this.artist,
      artistAr: artistAr ?? this.artistAr,
      categoryId: categoryId ?? this.categoryId,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
      isLocked: isLocked ?? this.isLocked,
      requiredSubscription: requiredSubscription ?? this.requiredSubscription,
      downloadCount: downloadCount ?? this.downloadCount,
      playCount: playCount ?? this.playCount,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt,
    );
  }
}
