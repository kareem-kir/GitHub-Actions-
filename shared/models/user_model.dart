// Removed Firebase import

enum SubscriptionStatus { free, weekly, monthly, yearly }

class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String displayName;
  final SubscriptionStatus status;
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;
  final DateTime lastActive;
  final List<String> downloadedTracks;
  final int totalDownloads;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.displayName,
    required this.status,
    this.subscriptionExpiry,
    required this.createdAt,
    required this.lastActive,
    required this.downloadedTracks,
    required this.totalDownloads,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      displayName: json['display_name'] ?? '',
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.free,
      ),
      subscriptionExpiry: json['subscription_expiry'] != null
        ? DateTime.parse(json['subscription_expiry'])
        : null,
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
      lastActive: json['last_active'] != null
        ? DateTime.parse(json['last_active'])
        : DateTime.now(),
      downloadedTracks: List<String>.from(json['downloaded_tracks'] ?? []),
      totalDownloads: json['total_downloads'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'status': status.name,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'last_active': lastActive.toIso8601String(),
      'downloaded_tracks': downloadedTracks,
      'total_downloads': totalDownloads,
    };
  }

  bool get isSubscriptionActive {
    if (status == SubscriptionStatus.free) return true;
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  bool canAccessContent(SubscriptionStatus requiredStatus) {
    if (requiredStatus == SubscriptionStatus.free) return true;
    if (!isSubscriptionActive) return false;
    
    final statusLevels = {
      SubscriptionStatus.free: 0,
      SubscriptionStatus.weekly: 1,
      SubscriptionStatus.monthly: 2,
      SubscriptionStatus.yearly: 3,
    };
    
    return statusLevels[status]! >= statusLevels[requiredStatus]!;
  }

  UserModel copyWith({
    String? phone,
    String? email,
    String? displayName,
    SubscriptionStatus? status,
    DateTime? subscriptionExpiry,
    DateTime? lastActive,
    List<String>? downloadedTracks,
    int? totalDownloads,
  }) {
    return UserModel(
      id: id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
      downloadedTracks: downloadedTracks ?? this.downloadedTracks,
      totalDownloads: totalDownloads ?? this.totalDownloads,
    );
  }
}
