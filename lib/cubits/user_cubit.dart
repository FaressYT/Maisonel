import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user.dart';

class UserCubit extends Cubit<User?> {
  UserCubit() : super(null);

  void setUser(User? user) {
    emit(user);
  }

  void updateUser(User user) {
    emit(user);
  }

  void clearUser() {
    emit(null);
  }
}
