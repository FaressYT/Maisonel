import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    // In a real app, you'd check for a stored token here.
    // For now, we'll assume unauthenticated on startup
    emit(AuthUnauthenticated());
  }

  Future<void> login(String phone, String password) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.login(phone, password);
      // We'll pass a map for now, but in future updates we can pass the User object directly
      emit(
        AuthAuthenticated(
          user: result.user.toJson(),
          token: ApiService.token ?? '',
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
    required String birthDate,
    XFile? photo,
    XFile? idDocument,
  }) async {
    emit(AuthLoading());
    try {
      final user = await ApiService.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        birthDate: birthDate,
        photo: photo,
        idDocument: idDocument,
      );
      emit(
        AuthAuthenticated(user: user.toJson(), token: ApiService.token ?? ''),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await ApiService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails server-side, we clear local state
      emit(AuthUnauthenticated());
    }
  }
}
