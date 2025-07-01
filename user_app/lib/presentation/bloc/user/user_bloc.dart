import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/firebase_service.dart';

// Events
abstract class UserEvent {}

class LoadUserData extends UserEvent {}

class UpdateUserData extends UserEvent {
  final UserModel user;
  UpdateUserData(this.user);
}

class RefreshUserData extends UserEvent {}

// States
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded(this.user);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<LoadUserData>(_onLoadUserData);
    on<UpdateUserData>(_onUpdateUserData);
    on<RefreshUserData>(_onRefreshUserData);
  }

  Future<void> _onLoadUserData(LoadUserData event, Emitter<UserState> emit) async {
    emit(UserLoading());
    
    try {
      final userId = FirebaseService.currentUserId;
      if (userId == null) {
        emit(UserError('المستخدم غير مسجل الدخول'));
        return;
      }

      await emit.forEach(
        FirebaseService.getUserStream(userId),
        onData: (UserModel? user) {
          if (user != null) {
            return UserLoaded(user);
          } else {
            return UserError('لم يتم العثور على بيانات المستخدم');
          }
        },
        onError: (error, stackTrace) => UserError('فشل في تحميل بيانات المستخدم'),
      );
    } catch (e) {
      emit(UserError('فشل في تحميل بيانات المستخدم'));
    }
  }

  Future<void> _onUpdateUserData(UpdateUserData event, Emitter<UserState> emit) async {
    try {
      await FirebaseService.createOrUpdateUser(event.user);
      emit(UserLoaded(event.user));
    } catch (e) {
      emit(UserError('فشل في تحديث بيانات المستخدم'));
    }
  }

  Future<void> _onRefreshUserData(RefreshUserData event, Emitter<UserState> emit) async {
    add(LoadUserData());
  }
}
