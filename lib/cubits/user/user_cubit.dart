import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/api_service.dart';
import '../../models/property.dart';
import '../../models/payment_method.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  Future<void> loadUserData() async {
    emit(UserLoading());
    try {
      final favorites = await ApiService.getFavorites();
      final creditCards = (await ApiService.getCreditCards())
          .cast<PaymentMethod>();
      emit(UserLoaded(favorites: favorites, creditCards: creditCards));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> toggleFavorite(String appId) async {
    // Optimistic update could be tricky with lists, so we'll just reload for now
    emit(UserLoading());
    try {
      await ApiService.toggleFavorite(appId);
      await loadUserData(); // Refresh
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> addCreditCard({
    required String holderName,
    required String cardNumber,
    required String expirationDate,
    required String cvv,
  }) async {
    emit(UserLoading());
    try {
      await ApiService.addCreditCard(
        holderName: holderName,
        cardNumber: cardNumber,
        expirationDate: expirationDate,
        cvv: cvv,
      );
      await loadUserData(); // Refresh
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
