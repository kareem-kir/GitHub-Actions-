import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/track_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Auth Methods
  static User? get currentUser => _client.auth.currentUser;
  static String? get currentUserId => _client.auth.currentUser?.id;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://judwkuinzlhiblozulwv.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1ZHdrdWluemxoaWJsb3p1bHd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzMzQzNjEsImV4cCI6MjA2NjkxMDM2MX0.WDTmThQPkM7gAHYAFidHVg_xp6dryRxClmYFAtM1MvI',
    );
  }

  // Auth Methods
  static Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // User Methods
  static Future<UserModel?> getCurrentUserData() async {
    if (currentUserId == null) return null;
    
    final response = await _client
        .from('users')
        .select()
        .eq('id', currentUserId!)
        .maybeSingle();
    
    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  static Future<void> createOrUpdateUser(UserModel user) async {
    await _client.from('users').upsert(user.toJson());
  }

  static Stream<UserModel?> getUserStream(String userId) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromJson(data.first);
        });
  }

  static Future<List<UserModel>> searchUsers(String query) async {
    final response = await _client
        .from('users')
        .select()
        .or('email.ilike.%$query%,display_name.ilike.%$query%,id.eq.$query');

    return response.map((json) => UserModel.fromJson(json)).toList();
  }

  // Category Methods
  static Stream<List<CategoryModel>> getCategoriesStream() {
    return _client
        .from('categories')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('order_index')
        .map((data) => data.map((json) => CategoryModel.fromJson(json)).toList());
  }

  static Future<void> createCategory(CategoryModel category) async {
    await _client.from('categories').insert(category.toJson());
  }

  static Future<void> updateCategory(CategoryModel category) async {
    await _client
        .from('categories')
        .update(category.toJson())
        .eq('id', category.id);
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _client
        .from('categories')
        .update({'is_active': false})
        .eq('id', categoryId);
  }

  // Track Methods
  static Stream<List<TrackModel>> getTracksStream(String categoryId) {
    return _client
        .from('tracks')
        .stream(primaryKey: ['id'])
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('order_index')
        .map((data) => data.map((json) => TrackModel.fromJson(json)).toList());
  }

  static Future<void> createTrack(TrackModel track) async {
    await _client.from('tracks').insert(track.toJson());
  }

  static Future<void> updateTrack(TrackModel track) async {
    await _client
        .from('tracks')
        .update(track.toJson())
        .eq('id', track.id);
  }

  static Future<void> deleteTrack(String trackId) async {
    await _client
        .from('tracks')
        .update({'is_active': false})
        .eq('id', trackId);
  }

  static Future<void> incrementTrackPlayCount(String trackId) async {
    await _client.rpc('increment_play_count', params: {'track_id': trackId});
  }

  static Future<void> incrementTrackDownloadCount(String trackId) async {
    await _client.rpc('increment_download_count', params: {'track_id': trackId});
  }

  // Storage Methods
  static Future<String> uploadFile(String bucket, String path, List<int> bytes) async {
    await _client.storage.from(bucket).uploadBinary(path, bytes);
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  static Future<void> deleteFile(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }

  // Admin Methods
  static Future<Map<String, dynamic>?> getAdminData(String userId) async {
    final response = await _client
        .from('admins')
        .select()
        .eq('id', userId)
        .eq('is_active', true)
        .maybeSingle();
    
    return response;
  }

  // App Settings
  static Future<Map<String, dynamic>?> getAppSettings() async {
    final response = await _client
        .from('app_settings')
        .select()
        .eq('key', 'general')
        .maybeSingle();
    
    return response?['value'];
  }

  static Future<void> updateAppSettings(Map<String, dynamic> settings) async {
    await _client.from('app_settings').upsert({
      'key': 'general',
      'value': settings,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Real-time subscriptions
  static RealtimeChannel subscribeToUserChanges(String userId, Function(UserModel?) callback) {
    return _client
        .channel('user_changes_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              callback(UserModel.fromJson(payload.newRecord!));
            } else {
              callback(null);
            }
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToCategoryChanges(Function(List<CategoryModel>) callback) {
    return _client
        .channel('category_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categories',
          callback: (payload) async {
            // Refresh categories when any change occurs
            final response = await _client
                .from('categories')
                .select()
                .eq('is_active', true)
                .order('order_index');
            
            final categories = response.map((json) => CategoryModel.fromJson(json)).toList();
            callback(categories);
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToTrackChanges(String categoryId, Function(List<TrackModel>) callback) {
    return _client
        .channel('track_changes_$categoryId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tracks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'category_id',
            value: categoryId,
          ),
          callback: (payload) async {
            // Refresh tracks when any change occurs
            final response = await _client
                .from('tracks')
                .select()
                .eq('category_id', categoryId)
                .eq('is_active', true)
                .order('order_index');
            
            final tracks = response.map((json) => TrackModel.fromJson(json)).toList();
            callback(tracks);
          },
        )
        .subscribe();
  }
}
