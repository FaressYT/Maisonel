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
      final creditCardsRaw = await ApiService.getCreditCards();
      final creditCards = creditCardsRaw
          .whereType<Map<String, dynamic>>()
          .map(PaymentMethod.fromJson)
          .toList();
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
    required String cardType,
  }) async {
    emit(UserLoading());
    try {
      await ApiService.addCreditCard(
        holderName: holderName,
        cardNumber: cardNumber,
        expirationDate: expirationDate,
        cvv: cvv,
        cardType: cardType,
      );
      await loadUserData(); // Refresh
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<String> deleteCreditCard(String id) async {
    emit(UserLoading());
    try {
      final message = await ApiService.deleteCreditCard(id);
      await loadUserData(); // Refresh
      return message;
    } catch (e) {
      emit(UserError(e.toString()));
      rethrow;
    }
  }
}
