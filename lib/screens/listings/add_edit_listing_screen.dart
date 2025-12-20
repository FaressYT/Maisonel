import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/property.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  String _selectedType = 'Apartment';
  bool _isLoading = false;

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
    _bedroomsController = TextEditingController(
      text: widget.property?.bedrooms.toString(),
    );
    _bathroomsController = TextEditingController(
      text: widget.property?.bathrooms.toString(),
    );

    if (widget.property != null) {
      _selectedType = widget.property!.propertyType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  void _saveListing() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.property == null
                  ? 'Listing published successfully!'
                  : 'Listing updated successfully!',
            ),
          ),
        );
        Navigator.pop(context);
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
              // Image Upload Placeholder
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Photos',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
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
