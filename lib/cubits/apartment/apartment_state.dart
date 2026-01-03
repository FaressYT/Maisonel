part of 'apartment_cubit.dart';

abstract class ApartmentState extends Equatable {
  const ApartmentState();

  @override
  List<Object> get props => [];
}

class ApartmentInitial extends ApartmentState {}

class ApartmentLoading extends ApartmentState {}

class ApartmentLoaded extends ApartmentState {
  final List<Property> availableApartments;
  final List<Property> ownedApartments;

  const ApartmentLoaded({
    this.availableApartments = const [],
    this.ownedApartments = const [],
  });

  @override
  List<Object> get props => [availableApartments, ownedApartments];

  ApartmentLoaded copyWith({
    List<Property>? availableApartments,
    List<Property>? ownedApartments,
  }) {
    return ApartmentLoaded(
      availableApartments: availableApartments ?? this.availableApartments,
      ownedApartments: ownedApartments ?? this.ownedApartments,
    );
  }
}

class ApartmentError extends ApartmentState {
  final String message;

  const ApartmentError(this.message);

  @override
  List<Object> get props => [message];
}
