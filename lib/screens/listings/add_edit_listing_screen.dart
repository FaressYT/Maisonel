import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maisonel_v02/services/api_service.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../cubits/apartment/apartment_cubit.dart';

class AddEditListingScreen extends StatefulWidget {
  final Property? property; // If null, we are adding new listing

  const AddEditListingScreen({super.key, this.property});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _cityController;
  late TextEditingController _sizeController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _amenityController;
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  String _selectedType = 'Apartment';
  bool _isLoading = false;
  final List<String> _amenities = [];

  final List<String> _propertyTypes = [
    'Apartment',
    'House',
    'Villa',
    'Studio',
    'Loft',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property?.title);
    _descriptionController = TextEditingController(
      text: widget.property?.description,
    );
    _priceController = TextEditingController(
      text: widget.property?.price.toString(),
    );
    _locationController = TextEditingController(
      text: widget.property?.location,
    );
    _cityController = TextEditingController(text: widget.property?.city);
    _sizeController = TextEditingController(
      text: widget.property?.area.toString(),
    );
    _bedroomsController = TextEditingController(
      text: widget.property?.bedrooms.toString(),
    );
    _bathroomsController = TextEditingController(
      text: widget.property?.bathrooms.toString(),
    );
    _amenityController = TextEditingController();

    if (widget.property != null) {
      _selectedType = widget.property!.propertyType;
      _amenities.addAll(widget.property!.amenities);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _sizeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _amenityController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _deleteExistingImage(int index) async {
    if (widget.property == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<ApartmentCubit>().deleteApartmentImage(
          widget.property!.id,
          index,
        );
        setState(() {
          widget.property!.images.removeAt(index);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _addAmenity() {
    final raw = _amenityController.text.trim();
    if (raw.isEmpty) return;
    final items = raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items.isEmpty) return;
    setState(() {
      for (final item in items) {
        final exists = _amenities.any(
          (amenity) => amenity.toLowerCase() == item.toLowerCase(),
        );
        if (!exists) {
          _amenities.add(item);
        }
      }
      _amenityController.clear();
    });
  }

  void _removeAmenity(String amenity) {
    setState(() {
      _amenities.remove(amenity);
    });
  }

  void _saveListing() async {
    if (_formKey.currentState!.validate()) {
      // Validation for images in create mode
      if (widget.property == null && _selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one photo')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.property == null) {
          // Create
          await context.read<ApartmentCubit>().createApartment(
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            size: double.parse(_sizeController.text),
            city: _cityController.text,
            location: _locationController.text,
            bedrooms: int.parse(_bedroomsController.text),
            bathrooms: int.parse(_bathroomsController.text),
            type: _selectedType,
            images: _selectedImages,
            amenities: _amenities,
          );
        } else {
          // Update
          await context.read<ApartmentCubit>().updateApartment(
            widget.property!.id,
            title: _titleController.text,
            description: _descriptionController.text,
            price: double.parse(_priceController.text),
            size: double.parse(_sizeController.text),
            city: _cityController.text,
            location: _locationController.text,
            bedrooms: int.parse(_bedroomsController.text),
            bathrooms: int.parse(_bathroomsController.text),
            type: _selectedType,
            images: _selectedImages.isEmpty ? null : _selectedImages,
            amenities: _amenities,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.property == null
                    ? 'Listing published successfully!'
                    : 'Listing updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.property == null ? 'Add New Listing' : 'Edit Listing',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Title',
                controller: _titleController,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price per night',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Type',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            hintText: 'Select Type',
                            hintStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                          items: _propertyTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Location / Address',
                controller: _locationController,
                prefixIcon: Icons.location_on_outlined,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'City',
                      controller: _cityController,
                      prefixIcon: Icons.location_city,
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomTextField(
                      label: 'Size (sqm)',
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.aspect_ratio,
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Bedrooms',
                      controller: _bedroomsController,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomTextField(
                      label: 'Bathrooms',
                      controller: _bathroomsController,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amenityController,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _addAmenity(),
                          decoration: InputDecoration(
                            hintText: 'Add amenity (comma separated)',
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: _addAmenity,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_amenities.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _amenities.map((amenity) {
                        return Chip(
                          label: Text(amenity),
                          onDeleted: () => _removeAmenity(amenity),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Image Upload Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Add Button
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),

                        // Existing Images
                        if (widget.property != null)
                          ...widget.property!.images.asMap().entries.map((
                            entry,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    child: Image.network(
                                      ApiService.getImageUrl(entry.value) ?? '',
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 100,
                                                width: 100,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.error),
                                              ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _deleteExistingImage(entry.key),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                        // New Selected Images
                        ..._selectedImages.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  child: Image.file(
                                    File(entry.value.path),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _removeSelectedImage(entry.key),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
              CustomButton(
                text: widget.property == null
                    ? 'Publish Listing'
                    : 'Save Changes',
                onPressed: _saveListing,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
