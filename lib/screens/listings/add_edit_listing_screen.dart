import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p; // لاستخراج اسم الملف بشكل صحيح
import '../../theme.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditListingScreen extends StatefulWidget {
  final Property? property;

  const AddEditListingScreen({super.key, this.property});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // التحكم بالحقول
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;

  // الحقول المطلوبة للـ API (City & Size)
  final TextEditingController _sizeController = TextEditingController(
    text: "240",
  );
  final TextEditingController _cityController = TextEditingController(
    text: "Aleppo",
  );

  String _selectedType = 'Apartment';
  bool _isLoading = false;

  // قائمة الصور والـ Picker
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

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
    _sizeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // دالة اختيار الصور (تطلب الإذن وتفتح المعرض)
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80, // لتقليل الحجم لسرعة الرفع
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            images.map((image) => File(image.path)).toList(),
          );
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
      _showErrorSnackBar("فشل الوصول إلى المعرض، يرجى التحقق من الإذونات.");
    }
  }

  // دالة الحفظ النهائية
  void _saveListing() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty && widget.property == null) {
        _showErrorSnackBar("يرجى اختيار صورة واحدة على الأقل للعقار.");
        return;
      }

      setState(() => _isLoading = true);

      // استدعاء الـ API الجديد storeApartment
      final bool success = await ApiService.storeApartment(
        city: _cityController.text,
        size: _sizeController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        price: _priceController.text,
        bedrooms: _bedroomsController.text,
        bathrooms: _bathroomsController.text,
        type: _selectedType.toLowerCase(),
        location: _locationController.text,
        images: _selectedImages,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          _showSuccessSnackBar("تم نشر العقار بنجاح!");
          Navigator.pop(context, true);
        } else {
          _showErrorSnackBar("فشل في عملية الحفظ، يرجى المحاولة لاحقاً.");
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
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
                  Expanded(child: _buildTypeDropdown()),
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

              // قسم اختيار الصور مع العرض
              Text(
                'Property Photos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildImageSelectorArea(),

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

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Type',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          items: _propertyTypes
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) => setState(() => _selectedType = value!),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSelectorArea() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: _selectedImages.isEmpty
          ? InkWell(
              onTap: _pickImages,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to add photos',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 30),
                    onPressed: _pickImages,
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedImages.removeAt(index)),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
