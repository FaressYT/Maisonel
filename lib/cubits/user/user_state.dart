part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<Property> favorites;
  final List<PaymentMethod> creditCards;
  // Add User profile data if separate from Auth

  const UserLoaded({this.favorites = const [], this.creditCards = const []});

  @override
  List<Object> get props => [favorites, creditCards];

  UserLoaded copyWith({
    List<Property>? favorites,
    List<PaymentMethod>? creditCards,
  }) {
    return UserLoaded(
      favorites: favorites ?? this.favorites,
      creditCards: creditCards ?? this.creditCards,
    );
  }
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
