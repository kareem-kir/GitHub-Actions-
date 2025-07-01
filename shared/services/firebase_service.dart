import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/track_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String categoriesCollection = 'categories';
  static const String tracksCollection = 'tracks';
  static const String adminsCollection = 'admins';
  static const String appSettingsCollection = 'app_settings';

  // Auth Methods
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  static Future<UserCredential> signInWithPhone(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Methods
  static Future<UserModel?> getCurrentUserData() async {
    if (currentUserId == null) return null;
    final doc = await _firestore.collection(usersCollection).doc(currentUserId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  static Future<void> createOrUpdateUser(UserModel user) async {
    await _firestore.collection(usersCollection).doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
  }

  static Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection(usersCollection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  static Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .where('phone', isGreaterThanOrEqualTo: query)
        .where('phone', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Category Methods
  static Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(categoriesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }

  static Future<void> createCategory(CategoryModel category) async {
    await _firestore.collection(categoriesCollection).add(category.toFirestore());
  }

  static Future<void> updateCategory(CategoryModel category) async {
    await _firestore.collection(categoriesCollection).doc(category.id).update(category.toFirestore());
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection(categoriesCollection).doc(categoryId).update({'isActive': false});
  }

  // Track Methods
  static Stream<List<TrackModel>> getTracksStream(String categoryId) {
    return _firestore
        .collection(tracksCollection)
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TrackModel.fromFirestore(doc)).toList());
  }

  static Future<void> createTrack(TrackModel track) async {
    await _firestore.collection(tracksCollection).add(track.toFirestore());
  }

  static Future<void> updateTrack(TrackModel track) async {
    await _firestore.collection(tracksCollection).doc(track.id).update(track.toFirestore());
  }

  static Future<void> deleteTrack(String trackId) async {
    await _firestore.collection(tracksCollection).doc(trackId).update({'isActive': false});
  }

  static Future<void> incrementTrackPlayCount(String trackId) async {
    await _firestore.collection(tracksCollection).doc(trackId).update({
      'playCount': FieldValue.increment(1),
    });
  }

  static Future<void> incrementTrackDownloadCount(String trackId) async {
    await _firestore.collection(tracksCollection).doc(trackId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  // Storage Methods
  static Future<String> uploadFile(String path, List<int> bytes) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putData(bytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  static Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // App Settings
  static Future<Map<String, dynamic>?> getAppSettings() async {
    final doc = await _firestore.collection(appSettingsCollection).doc('general').get();
    return doc.data();
  }

  static Future<void> updateAppSettings(Map<String, dynamic> settings) async {
    await _firestore.collection(appSettingsCollection).doc('general').set(settings, SetOptions(merge: true));
  }
}
