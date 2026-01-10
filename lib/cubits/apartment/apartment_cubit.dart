import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../models/property.dart';

part 'apartment_state.dart';

class ApartmentCubit extends Cubit<ApartmentState> {
  ApartmentCubit() : super(ApartmentInitial());

  Future<void> loadApartments() async {
    emit(ApartmentLoading());
    try {
      final available = await ApiService.getAvailableApartments();
      final owned = await ApiService.getOwnedApartments();
      emit(
        ApartmentLoaded(availableApartments: available, ownedApartments: owned),
      );
    } catch (e) {
      emit(ApartmentError(e.toString()));
      rethrow;
    }
  }

  Future<void> createApartment({
    required String title,
    required String description,
    required double price,
    required double size,
    required String city,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required String type,
    required List<XFile> images,
    List<String> amenities = const [],
  }) async {
    emit(ApartmentLoading());
    try {
      await ApiService.createApartment(
        title: title,
        description: description,
        price: price,
        size: size,
        city: city,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        type: type,
        images: images,
        amenities: amenities,
      );
      await loadApartments(); // Reload lists
    } catch (e) {
      emit(ApartmentError(e.toString()));
      rethrow;
    }
  }

  Future<void> updateApartment(
    String id, {
    String? title,
    String? description,
    double? price,
    double? size,
    String? location,
    String? type,
    int? bedrooms,
    int? bathrooms,
    String? city,
    List<String>? amenities,
    List<XFile>? images,
  }) async {
    emit(ApartmentLoading());
    try {
      await ApiService.updateApartment(
        id,
        title: title,
        description: description,
        price: price,
        size: size,
        location: location,
        type: type,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        city: city,
        amenities: amenities,
        images: images,
      );
      await loadApartments(); // Reload
    } catch (e) {
      emit(ApartmentError(e.toString()));
      rethrow;
    }
  }

  Future<void> deleteApartment(String id) async {
    emit(ApartmentLoading());
    try {
      await ApiService.deleteApartment(id);
      await loadApartments(); // Reload
    } catch (e) {
      emit(ApartmentError(e.toString()));
      rethrow;
    }
  }

  Future<void> toggleApartmentStatus(String id) async {
    emit(ApartmentLoading());
    try {
      await ApiService.toggleApartmentStatus(id);
      await loadApartments(); // Reload to get updated status
    } catch (e) {
      emit(ApartmentError(e.toString()));
      rethrow;
    }
  }

  Future<void> deleteApartmentImage(String id, int index) async {
    emit(ApartmentLoading());
    try {
      await ApiService.deleteApartmentImage(id, index);
      await loadApartments(); // Reload to get updated images
    } catch (e) {
      emit(ApartmentError(e.toString()));
      rethrow;
    }
  }
}
