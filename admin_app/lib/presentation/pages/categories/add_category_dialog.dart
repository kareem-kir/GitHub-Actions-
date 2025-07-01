import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../bloc/content/content_bloc.dart';
import '../../../shared/models/category_model.dart';

class AddCategoryDialog extends StatefulWidget {
  final CategoryModel? category;

  const AddCategoryDialog({Key? key, this.category}) : super(key: key);

  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _orderController = TextEditingController();
  
  bool _isActive = true;
  bool _isLocked = false;
  String _requiredSubscription = 'free';
  String? _imageUrl;
  PlatformFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final category = widget.category!;
    _nameController.text = category.name;
    _nameArController.text = category.nameAr;
    _descriptionController.text = category.description;
    _descriptionArController.text = category.descriptionAr;
    _orderController.text = category.order.toString();
    _isActive = category.isActive;
    _isLocked = category.isLocked;
    _requiredSubscription = category.requiredSubscription;
    _imageUrl = category.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentBloc, ContentState>(
      listener: (context, state) {
        if (state is ContentSuccess) {
          Navigator.of(context).pop();
        } else if (state is FileUploaded) {
          setState(() {
            _imageUrl = state.url;
          });
        }
      },
      child: Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  widget.category == null ? 'إضافة قسم جديد' : 'تعديل القسم',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                
                const SizedBox(height: 24),
                
                // Form Fields
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Name Fields
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'الاسم (English)',
                                  hintText: 'Category Name',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال اسم القسم';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _nameArController,
                                decoration: const InputDecoration(
                                  labelText: 'الاسم (العربية)',
                                  hintText: 'اسم القسم',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال اسم القسم بالعربية';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description Fields
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'الوصف (English)',
                            hintText: 'Category Description',
                          ),
                          maxLines: 2,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _descriptionArController,
                          decoration: const InputDecoration(
                            labelText: 'الوصف (العربية)',
                            hintText: 'وصف القسم',
                          ),
                          maxLines: 2,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Order and Settings
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _orderController,
                                decoration: const InputDecoration(
                                  labelText: 'ترتيب العرض',
                                  hintText: '1',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال ترتيب العرض';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'يرجى إدخال رقم صحيح';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _requiredSubscription,
                                decoration: const InputDecoration(
                                  labelText: 'نوع الاشتراك المطلوب',
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'free', child: Text('مجاني')),
                                  DropdownMenuItem(value: 'weekly', child: Text('أسبوعي')),
                                  DropdownMenuItem(value: 'monthly', child: Text('شهري')),
                                  DropdownMenuItem(value: 'yearly', child: Text('سنوي')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _requiredSubscription = value!;
                                    _isLocked = value != 'free';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Image Upload
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'صورة القسم',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              if (_imageUrl != null) ...[
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(_imageUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.upload),
                                    label: Text(_imageUrl == null ? 'اختيار صورة' : 'تغيير الصورة'),
                                  ),
                                  if (_imageUrl != null) ...[
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _imageUrl = null;
                                          _selectedImage = null;
                                        });
                                      },
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      label: const Text('حذف', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Switches
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: const Text('نشط'),
                                subtitle: const Text('عرض القسم في التطبيق'),
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile(
                                title: const Text('مقفول'),
                                subtitle: const Text('يتطلب اشتراك'),
                                value: _isLocked,
                                onChanged: (value) {
                                  setState(() {
                                    _isLocked = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 16),
                    BlocBuilder<ContentBloc, ContentState>(
                      builder: (context, state) {
                        final isLoading = state is ContentLoading || state is FileUploading;
                        
                        return ElevatedButton(
                          onPressed: isLoading ? null : _saveCategory,
                          child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.category == null ? 'إضافة' : 'تحديث'),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImage = result.files.first;
      });

      // Upload image
      context.read<ContentBloc>().add(
        UploadFile(
          _selectedImage!,
          'category_images/${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}',
        ),
      );
    }
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final category = CategoryModel(
      id: widget.category?.id ?? '',
      name: _nameController.text.trim(),
      nameAr: _nameArController.text.trim(),
      description: _descriptionController.text.trim(),
      descriptionAr: _descriptionArController.text.trim(),
      imageUrl: _imageUrl ?? '',
      isLocked: _isLocked,
      requiredSubscription: _requiredSubscription,
      order: int.parse(_orderController.text.trim()),
      isActive: _isActive,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
    );

    if (widget.category == null) {
      context.read<ContentBloc>().add(CreateCategory(category));
    } else {
      context.read<ContentBloc>().add(UpdateCategory(category));
    }
  }
}
