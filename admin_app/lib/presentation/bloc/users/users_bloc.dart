import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/firebase_service.dart';

// Events
abstract class UsersEvent {}

class SearchUsers extends UsersEvent {
  final String query;
  SearchUsers(this.query);
}

class LoadAllUsers extends UsersEvent {}

class UpdateUserSubscription extends UsersEvent {
  final String userId;
  final SubscriptionStatus status;
  final DateTime? expiryDate;
  UpdateUserSubscription(this.userId, this.status, {this.expiryDate});
}

class LoadUserDetails extends UsersEvent {
  final String userId;
  LoadUserDetails(this.userId);
}

// States
abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserModel> users;
  final String? searchQuery;
  UsersLoaded(this.users, {this.searchQuery});
}

class UserDetailsLoaded extends UsersState {
  final UserModel user;
  UserDetailsLoaded(this.user);
}

class UsersSuccess extends UsersState {
  final String message;
  UsersSuccess(this.message);
}

class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}

// BLoC
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersInitial()) {
    on<SearchUsers>(_onSearchUsers);
    on<LoadAllUsers>(_onLoadAllUsers);
    on<UpdateUserSubscription>(_onUpdateUserSubscription);
    on<LoadUserDetails>(_onLoadUserDetails);
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<UsersState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(UsersLoaded([], searchQuery: event.query));
      return;
    }

    emit(UsersLoading());
    
    try {
      final users = await FirebaseService.searchUsers(event.query.trim());
      emit(UsersLoaded(users, searchQuery: event.query));
    } catch (e) {
      emit(UsersError('فشل في البحث عن المستخدمين'));
    }
  }

  Future<void> _onLoadAllUsers(LoadAllUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    
    try {
      // This would require implementing a method to get all users
      // For now, we'll emit an empty list
      emit(UsersLoaded([]));
    } catch (e) {
      emit(UsersError('فشل في تحميل المستخدمين'));
    }
  }

  Future<void> _onUpdateUserSubscription(UpdateUserSubscription event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    
    try {
      // Get current user data
      final currentState = state;
      UserModel? user;
      
      if (currentState is UsersLoaded) {
        user = currentState.users.firstWhere((u) => u.id == event.userId);
      } else if (currentState is UserDetailsLoaded) {
        user = currentState.user;
      }
      
      if (user == null) {
        emit(UsersError('لم يتم العثور على المستخدم'));
        return;
      }

      // Update user subscription
      final updatedUser = user.copyWith(
        status: event.status,
        subscriptionExpiry: event.expiryDate,
      );

      await FirebaseService.createOrUpdateUser(updatedUser);
      emit(UsersSuccess('تم تحديث اشتراك المستخدم بنجاح'));
      
      // Reload user details if we were viewing a specific user
      if (currentState is UserDetailsLoaded) {
        emit(UserDetailsLoaded(updatedUser));
      }
    } catch (e) {
      emit(UsersError('فشل في تحديث اشتراك المستخدم'));
    }
  }

  Future<void> _onLoadUserDetails(LoadUserDetails event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    
    try {
      await emit.forEach(
        FirebaseService.getUserStream(event.userId),
        onData: (UserModel? user) {
          if (user != null) {
            return UserDetailsLoaded(user);
          } else {
            return UsersError('لم يتم العثور على المستخدم');
          }
        },
        onError: (error, stackTrace) => UsersError('فشل في تحميل بيانات المستخدم'),
      );
    } catch (e) {
      emit(UsersError('فشل في تحميل بيانات المستخدم'));
    }
  }
}
