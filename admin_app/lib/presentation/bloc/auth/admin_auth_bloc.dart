import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/services/firebase_service.dart';

// Events
abstract class AdminAuthEvent {}

class CheckAdminAuthStatus extends AdminAuthEvent {}

class AdminSignIn extends AdminAuthEvent {
  final String email;
  final String password;
  AdminSignIn(this.email, this.password);
}

class AdminSignOut extends AdminAuthEvent {}

// States
abstract class AdminAuthState {}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

class AdminAuthUnauthenticated extends AdminAuthState {}

class AdminAuthAuthenticated extends AdminAuthState {
  final AdminUser admin;
  AdminAuthAuthenticated(this.admin);
}

class AdminAuthError extends AdminAuthState {
  final String message;
  AdminAuthError(this.message);
}

// Admin User Model
class AdminUser {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final List<String> permissions;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.permissions,
    required this.isActive,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'admin',
      permissions: List<String>.from(data['permissions'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }
}

// BLoC
class AdminAuthBloc extends Bloc<AdminAuthEvent, AdminAuthState> {
  AdminAuthBloc() : super(AdminAuthInitial()) {
    on<CheckAdminAuthStatus>(_onCheckAdminAuthStatus);
    on<AdminSignIn>(_onAdminSignIn);
    on<AdminSignOut>(_onAdminSignOut);
  }

  Future<void> _onCheckAdminAuthStatus(CheckAdminAuthStatus event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Check if user is admin
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(currentUser.uid)
            .get();
        
        if (adminDoc.exists && adminDoc.data()?['isActive'] == true) {
          final admin = AdminUser.fromFirestore(adminDoc);
          emit(AdminAuthAuthenticated(admin));
        } else {
          await FirebaseAuth.instance.signOut();
          emit(AdminAuthUnauthenticated());
        }
      } else {
        emit(AdminAuthUnauthenticated());
      }
    } catch (e) {
      emit(AdminAuthError('حدث خطأ في التحقق من حالة المصادقة'));
    }
  }

  Future<void> _onAdminSignIn(AdminSignIn event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    
    try {
      // Sign in with email and password
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Check if user is admin
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();

      if (adminDoc.exists && adminDoc.data()?['isActive'] == true) {
        final admin = AdminUser.fromFirestore(adminDoc);
        emit(AdminAuthAuthenticated(admin));
      } else {
        await FirebaseAuth.instance.signOut();
        emit(AdminAuthError('ليس لديك صلاحية للوصول إلى لوحة التحكم'));
      }
    } on FirebaseAuthException catch (e) {
      String message = 'فشل في تسجيل الدخول';
      if (e.code == 'user-not-found') {
        message = 'البريد الإلكتروني غير مسجل';
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور غير صحيحة';
      } else if (e.code == 'invalid-email') {
        message = 'البريد الإلكتروني غير صحيح';
      } else if (e.code == 'too-many-requests') {
        message = 'تم تجاوز عدد المحاولات المسموح، حاول لاحقاً';
      }
      emit(AdminAuthError(message));
    } catch (e) {
      emit(AdminAuthError('حدث خطأ في تسجيل الدخول'));
    }
  }

  Future<void> _onAdminSignOut(AdminSignOut event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    
    try {
      await FirebaseAuth.instance.signOut();
      emit(AdminAuthUnauthenticated());
    } catch (e) {
      emit(AdminAuthError('فشل في تسجيل الخروج'));
    }
  }
}
