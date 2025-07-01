import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/models/user_model.dart';

// Events
abstract class AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class SignInWithPhone extends AuthEvent {
  final String phoneNumber;
  SignInWithPhone(this.phoneNumber);
}

class VerifyOTP extends AuthEvent {
  final String verificationId;
  final String otp;
  VerifyOTP(this.verificationId, this.otp);
}

class SignOut extends AuthEvent {}

class UpdateUserProfile extends AuthEvent {
  final String displayName;
  UpdateUserProfile(this.displayName);
}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthCodeSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  AuthCodeSent(this.verificationId, this.phoneNumber);
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithPhone>(_onSignInWithPhone);
    on<VerifyOTP>(_onVerifyOTP);
    on<SignOut>(_onSignOut);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        final userData = await FirebaseService.getCurrentUserData();
        if (userData != null) {
          emit(AuthAuthenticated(userData));
        } else {
          // Create user data if doesn't exist
          final newUser = UserModel(
            id: currentUser.uid,
            phone: currentUser.phoneNumber ?? '',
            displayName: currentUser.displayName ?? 'مستخدم جديد',
            status: SubscriptionStatus.free,
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
            downloadedTracks: [],
            totalDownloads: 0,
          );
          
          await FirebaseService.createOrUpdateUser(newUser);
          emit(AuthAuthenticated(newUser));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('حدث خطأ في التحقق من حالة المصادقة'));
    }
  }

  Future<void> _onSignInWithPhone(SignInWithPhone event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await FirebaseService.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto verification completed
          try {
            final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            await _handleSuccessfulSignIn(userCredential.user!, event.phoneNumber, emit);
          } catch (e) {
            emit(AuthError('فشل في تسجيل الدخول التلقائي'));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String message = 'فشل في إرسال رمز التحقق';
          if (e.code == 'invalid-phone-number') {
            message = 'رقم الهاتف غير صحيح';
          } else if (e.code == 'too-many-requests') {
            message = 'تم إرسال عدد كبير من الطلبات، حاول لاحقاً';
          }
          emit(AuthError(message));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(AuthCodeSent(verificationId, event.phoneNumber));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
    } catch (e) {
      emit(AuthError('حدث خطأ في إرسال رمز التحقق'));
    }
  }

  Future<void> _onVerifyOTP(VerifyOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await FirebaseService.signInWithPhone(
        event.verificationId,
        event.otp,
      );
      
      await _handleSuccessfulSignIn(
        userCredential.user!,
        userCredential.user!.phoneNumber ?? '',
        emit,
      );
    } catch (e) {
      String message = 'رمز التحقق غير صحيح';
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') {
          message = 'رمز التحقق غير صحيح';
        } else if (e.code == 'session-expired') {
          message = 'انتهت صلاحية رمز التحقق';
        }
      }
      emit(AuthError(message));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await FirebaseService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('فشل في تسجيل الخروج'));
    }
  }

  Future<void> _onUpdateUserProfile(UpdateUserProfile event, Emitter<AuthState> emit) async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      emit(AuthLoading());
      
      try {
        final updatedUser = currentState.user.copyWith(
          displayName: event.displayName,
          lastActive: DateTime.now(),
        );
        
        await FirebaseService.createOrUpdateUser(updatedUser);
        emit(AuthAuthenticated(updatedUser));
      } catch (e) {
        emit(AuthError('فشل في تحديث الملف الشخصي'));
        emit(AuthAuthenticated(currentState.user)); // Restore previous state
      }
    }
  }

  Future<void> _handleSuccessfulSignIn(User user, String phoneNumber, Emitter<AuthState> emit) async {
    try {
      // Check if user data exists
      UserModel? userData = await FirebaseService.getCurrentUserData();
      
      if (userData == null) {
        // Create new user
        userData = UserModel(
          id: user.uid,
          phone: phoneNumber,
          displayName: user.displayName ?? 'مستخدم جديد',
          status: SubscriptionStatus.free,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
          downloadedTracks: [],
          totalDownloads: 0,
        );
        
        await FirebaseService.createOrUpdateUser(userData);
      } else {
        // Update last active
        userData = userData.copyWith(lastActive: DateTime.now());
        await FirebaseService.createOrUpdateUser(userData);
      }
      
      emit(AuthAuthenticated(userData));
    } catch (e) {
      emit(AuthError('فشل في إنشاء بيانات المستخدم'));
    }
  }
}
