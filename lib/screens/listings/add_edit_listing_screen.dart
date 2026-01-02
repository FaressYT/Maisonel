import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _cityController;
  late TextEditingController _sizeController;

  String _selectedType = 'Apartment';
  bool _isLoading = false;

  final List<File> _selectedNewImages = []; // الصور الجديدة
  List<String> _existingImages = []; // صور السيرفر
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
    // تهيئة المتحكمات مع التأكد من عدم وجود قيم null
    _titleController = TextEditingController(
      text: widget.property?.title ?? "",
    );
    _descriptionController = TextEditingController(
      text: widget.property?.description ?? "",
    );
    _priceController = TextEditingController(
      text: widget.property?.price?.toString() ?? "",
    );
    _locationController = TextEditingController(
      text: widget.property?.location ?? "",
    );
    _bedroomsController = TextEditingController(
      text: widget.property?.bedrooms?.toString() ?? "",
    );
    _bathroomsController = TextEditingController(
      text: widget.property?.bathrooms?.toString() ?? "",
    );
    _cityController = TextEditingController(
      text: widget.property?.city ?? "Aleppo",
    );
    _sizeController = TextEditingController(
      text: widget.property?.area?.toString() ?? "100",
    );

    if (widget.property != null) {
      _selectedType = widget.property!.propertyType;
      _existingImages = List.from(widget.property!.images);
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
    _cityController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  // التابع المسؤول عن حذف الصورة من السيرفر باستخدام التوكن والرابط المحدث
  Future<void> _deleteImageFromServer(int index) async {
    if (widget.property == null) return;

    setState(() => _isLoading = true);

    // استدعاء التابع الذي أنشأناه في ApiService
    bool success = await ApiService.deleteApartmentImage(
      widget.property!.id.compareTo(widget.property!.id),
      index,
    );

    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _existingImages.removeAt(index);
      });
      _showMsg('تم حذف الصورة من السيرفر');
    } else {
      _showMsg('فشل حذف الصورة، تأكد من الاتصال', isError: true);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedNewImages.addAll(
          images.map((image) => File(image.path)).toList(),
        );
      });
    }
  }

  void _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    if (_existingImages.isEmpty && _selectedNewImages.isEmpty) {
      _showMsg('يرجى إضافة صورة واحدة على الأقل', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    bool success;

    if (widget.property == null) {
      // حالة الإضافة
      success = await ApiService.storeApartment(
        city: _cityController.text,
        size: _sizeController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        price: _priceController.text,
        bedrooms: _bedroomsController.text,
        bathrooms: _bathroomsController.text,
        type: _selectedType.toLowerCase(),
        location: _locationController.text,
        images: _selectedNewImages,
      );
    } else {
      // حالة التعديل
      success = await ApiService.updateApartment(
        id: widget.property!.id.compareTo(widget.property!.id),
        city: _cityController.text,
        size: _sizeController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        price: _priceController.text,
        bedrooms: _bedroomsController.text,
        bathrooms: _bathroomsController.text,
        type: _selectedType.toLowerCase(),
        location: _locationController.text,
        newImages: _selectedNewImages,
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      _showMsg('تمت العملية بنجاح');
      if (mounted) Navigator.pop(context, true);
    } else {
      _showMsg('حدث خطأ أثناء الحفظ', isError: true);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.property == null ? 'إضافة عقار جديد' : 'تعديل العقار',
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'العنوان',
                    controller: _titleController,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    label: 'الوصف',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'السعر',
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          items: _propertyTypes
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedType = v!),
                          decoration: const InputDecoration(labelText: 'النوع'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    label: 'الموقع / العنوان بالتفصيل',
                    controller: _locationController,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'صور العقار',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // تصميم عرض الصور
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // زر إضافة صور
                        IconButton(
                          onPressed: _pickImages,
                          icon: const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),

                        // الصور القديمة (من السيرفر)
                        ..._existingImages.asMap().entries.map(
                          (entry) => _buildPhotoItem(
                            url: entry.value,
                            onDelete: () => _deleteImageFromServer(entry.key),
                            isServer: true,
                          ),
                        ),

                        // الصور الجديدة (من الجهاز)
                        ..._selectedNewImages.asMap().entries.map(
                          (entry) => _buildPhotoItem(
                            file: entry.value,
                            onDelete: () => setState(
                              () => _selectedNewImages.removeAt(entry.key),
                            ),
                            isServer: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomButton(text: 'حفظ العقار', onPressed: _saveListing),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildPhotoItem({
    String? url,
    File? file,
    required VoidCallback onDelete,
    required bool isServer,
  }) {
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: isServer
                  ? NetworkImage(url!)
                  : FileImage(file!) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: isServer ? Colors.red : Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
